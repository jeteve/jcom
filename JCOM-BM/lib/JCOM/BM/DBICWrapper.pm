package JCOM::BM::DBICWrapper;
use Moose::Role;
use Moose::Meta::Class;
use Module::Pluggable::Object;

=head1 NAME

JCOM::BM::DBICWrapper - A Moose role to allow your business model to wrap business code around a dbic model.


=head1 SYNOPSIS

This package allows you to easily extend your DBIC Schema by Optionally wrapping its resultsets and result objects
in your own business classes.

=head2 Basic usage with no specific wrapping at all

 package My::App;
 use Moose;
 with qw/JCOM::BM::DBICWrapper/;
 1

Later

 my $schema = instance of DBIx schema
 my $app = My::App->new( { jcom_schema => $schema } );
 ## And use the dbic resultsets-ish methods.
 my $products = $app->dbic_factory('Product'); ## Get a new instance of the Product resultset.

 ## Use classic DBIC methods as usual.
 my $p = $products->find(2);
 my $blue_ps = $products->search({ colour => blue });


=head2 Implement your own product class with business methods.

First you need a DBIC factory that will wrap the raw dbic object into your own class of product

 package My::Model::DBICFactory::Product;
 use Moose; extends  qw/JCOM::BM::DBICFactory/ ;
 sub wrap{
   my ($self , $o) = @_;
   return My::Model::O::Product->new({o => $o , factory => $self });
 }
 1;

Then your Product business object class

 package My::Model::O::Product;
 use Moose;
 has 'o' => ( isa => 'My::Schema::Product', ## The raw DBIC object class.
              is => 'ro' , required => 1,
              handles => [ 'id' , 'name', 'active' ] ## handles standard properties
            );
 ## A business method
 sub activate{
    my ($self) = @_;
    $self->o->update({ active => 1 });
 }

Then from your main code, continue using the Product resultset as normal.

 my $product = $app->dbic_factory('Product')->find(1);
 ## But you can do
 $product->activate();
 ## so now
 $product->active() == 1;


=head2 Your own specialised resultset

Let's say you decide that from now, the bulk of your application should access only active products,
leaving unlimited access to all product to a limited set of places.

 package My::Model::DBICFactory::Product;
 use Moose;
 extends qw/JCOM::BM::DBICFactory/;
 sub build_dbic_rs{
     my ($self) = @_;
     ## Note that you can always access your original business model
     ## from a factory (method bm).
     return $self->bm->jcom_schema->resultset('Product')->search_rs({ active => 1});
     ## This is a simple example. You can restrict your products set
     ## according to any current property of your business model for instance.
 }
 sub wrap{ .. same .. }
 1;

Everywhere your application uses $app->dbic_factory('Product') is now
restricted to active products only.

Surely you want admin parts of your application to access all products.
So here's a very basic AllProducts:

 package My::Model::DBICFactory::AllProduct;
 use Moose; extends qw/My::Model::DBICFactory::Product/;
 sub build_dbic_rs{
   my ($self) = @_;
   ## Some extra security.
   unless( $self->bm->current_user()->is_admin() ){ confess "Sorry you cant access that"; }

   return $self->bm()->jcom_schema->resultset('Product')->search_rs();
 }


=cut

has 'jcom_schema' => ( is => 'rw' , isa => 'DBIx::Class::Schema' , required => 1 );
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

=head1 METHODS

=head2 dbic_factory

Returns a new instance of L<JCOM::BM::Factory> that wraps around the given DBIC ResultSet name
if such a resultset exists. Dies otherwise.

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
  my $instance = $class_name->new({  bm => $self , name => $name });
  my $dbic_rs = $instance->dbic_rs();
  return $instance;
}

1;
