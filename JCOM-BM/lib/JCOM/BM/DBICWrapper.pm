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
has '_jcom_dbic_factories' => ( is => 'ro' , isa => 'HashRef[JCOM::BM::DBICFactory]' , default => sub{ {};});

sub _build_jcom_fact_baseclass{
    my ($self) = @_;
    return ref ($self).'::Factory';
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

Returns a L<JCOM::BM::Factory> that wraps around the given DBIC ResultSet name.

usage:

    my $f = $this->jcom_factory('Article');

=cut
 
sub dbic_factory{
    my ($self , $name) = @_;
    
    if( my $f =  $self->_jcom_dbic_factories->{$name} ){
	return $f; # That's it.
    }

    my $class_name = $self->jcom_fact_baseclass().'::'.$name;
    unless( $self->_jcom_dbic_fact_classes->{$class_name} ){
	## We need to build such a class.
	$class_name = $self->jcom_fact_baseclass().'::Dynamic::'.$name;
	Moose::Meta::Class->create($class_name => ( superclasses => [ 'JCOM::BM::DBICFactory' ] ));
	$self->_jcom_dbic_fact_classes->{$class_name} = 1;
    }
    ## Ok, $class_name is now built
    ## Cache and return an instance of it.
    ## Note that the factory will built its own resultset from this model and the name
    return $self->_jcom_dbic_factories->{$name} = $class_name->new({  bm => $self , name => $name });
}

1;
