package JCOM::BM::DBICWrapper;
use Moose::Role;
use Moose::Meta::Class;
use Module::Pluggable::Object;

=head1 NAME

JCOM::BM::DBICWrapper - A Moose role to allow your business model to wrap business code around a dbic model.

=cut

has 'jcom_schema' => ( is => 'ro' , isa => 'DBIx::Class::Schema' , required => 1 );
has 'jcom_fact_baseclass' => ( is => 'ro' , isa => 'Str' , lazy_build => 1);

has '_jcom_dbic_fact_classes' => ( is => 'ro' , isa => 'HashRef[Bool]' , lazy_build => 1); 

sub _build_jcom_fact_baseclass{
    my ($self) = @_;
    return ref ($self).'::DBICFactory';
}

sub _build__jcom_dbic_fact_classes{
    my ($self) = @_;
    my $baseclass = $self->jcom_fact_baseclass();
    my $res = {};
    my $mp = Module::Pluggable::Object->new( search_path => [ $baseclass ]);
    foreach my $candidate_class ( $mp->plugins() ){
	Class::MOP::load_class( $candidate_class );
	# Code is loaded
	unless( $candidate_class->isa('JCOM::BM::DBICFactory') ){
	    warn "Class $candidate_class does not extend JCOM::BM::DBICFactory.";
	    next;
	}
	# And inherit from the right class.
	$res->{$candidate_class} = 1;
    }
    return $res;
}


=head2 dbic_factory

Returns a new instance of L<JCOM::BM::Factory> that wraps around the given DBIC ResultSet name.

usage:

    my $f = $this->jcom_factory('Article');

=cut

sub dbic_factory{
  my ($self , $name) = @_;
  unless( $name ){
    confess("Missing name in call to dbic_factory");
  }
  my $class_name = $self->jcom_fact_baseclass().'::'.$name;

  ## Build a class dynamically if necessary
  unless( $self->_jcom_dbic_fact_classes->{$class_name} ){
    ## We need to build such a class.
    Moose::Meta::Class->create($class_name => ( superclasses => [ 'JCOM::BM::DBICFactory' ] ));
    $self->_jcom_dbic_fact_classes->{$class_name} = 1;
  }
  ## Ok, $class_name is now there

  ## Note that the factory will built its own resultset from this model and the name
  return  $class_name->new({  bm => $self , name => $name });
}

1;
