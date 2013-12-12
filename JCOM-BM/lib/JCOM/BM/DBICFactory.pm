package JCOM::BM::DBICFactory;
use Moose;
extends qw/JCOM::BM::Factory/;

=head1 NAME

JCOM::BM::DBICFactory - A factory class that decorates a L<DBIx::Class::ResultSet>.

=head1 SYNOPSIS

A model implementing the role JCOM::BM::DBICWrapper will automatically instanciate
subclasses of this for any underlying DBIx::Class ResultSet.

To implement your own factory containing your business code for the underlying
DBIC resulsets, you need to subclass this.

=head1 PROPERTIES

=head2 dbic_rs

 The original L<DBIx::Class::ResultSet>. Mandatory.

=head2 bm

The business model consuming the role L<JCOM::BM::DBICWrapper>. Mandatory.

=cut

has 'dbic_rs' => ( is => 'ro' , isa => 'DBIx::Class::ResultSet', required => 1 , lazy_build => 1);
has 'bm' => ( is => 'ro' , does => 'JCOM::BM::DBICWrapper' , required => 1 , weak_ref => 1 );
has 'name' => ( is => 'ro' , isa => 'Str' , required => 1 );

sub _build_dbic_rs{
    my ($self) = @_;
    return $self->build_dbic_rs();
}

=head2 build_dbic_rs

Builds the dbic ResultSet to be wrapped by this factory.
You can override this in your business specific factories to build
specific resultsets.

=cut

sub build_dbic_rs{
  my ($self) = @_;
  my $resultset = eval{ return $self->bm->jcom_schema->resultset($self->name); };
  if( my $err = $@ ){
    confess("Cannot build resultset for $self NAME=".$self->name().' :'.$err);
  }
  return $resultset;
}


=head2 create

Creates a new object in the DBIC Schema and return it wrapped
using the wrapper method.

=cut

sub create{
    my ($self , $args) = @_;
    return $self->wrap($self->dbic_rs->create($args));
}

=head2 find

Finds an object in the DBIC schema and returns it wrapped
using the wrapper method.

=cut

sub find{
    my ($self , @rest) = @_;
    my $original = $self->dbic_rs->find(@rest);
    return $original ? $self->wrap($original) : undef;
}

=head2 first

Equivalent to DBIC Resultset 'first' method.

=cut

sub first{
  my ($self) = @_;
  my $original = $self->dbic_rs->first();
  return $original ? $self->wrap($original) : undef;
}

=head2 find_or_create

Wraps around the original DBIC find_or_create method.

=cut

sub find_or_create{
  my ($self , $args) = @_;
  my $original = $self->dbic_rs->find_or_create($args);
  return $original ? $self->wrap($original) : undef;
}


=head2 pager

Shortcut to underlying dbic_rs pager.

=cut

sub pager{
  my ($self) = @_;
  return $self->dbic_rs->pager();
}

=head2 delete

Shortcut to L<DBIx::Class::ResultSet> delete method of the
underlying dbic_rs


=cut

sub delete{
  my ($self , @rest) = @_;
  return $self->dbic_rs->delete(@rest);
}

=head2 get_column

Shortcut to the get_column of the decorated dbic_rs

=cut

sub get_column{
  my ($self, @rest) = @_;
  return $self->dbic_rs->get_column(@rest);
}

=head2 search_rs

Alias for search

=cut

sub search_rs{
  goto &search;
}

=head2 search

Search objects in the DBIC Schema and returns a new intance
of this factory.

=cut

sub search{
    my ($self , @rest) = @_;
    my $class = ref($self);
    return $class->new({ dbic_rs => $self->dbic_rs->search_rs(@rest),
			 bm => $self->bm(),
			 name => $self->name()
		       });
}


=head2 wrap

Wraps an L<DBIx::Class::Row> in a business object. By default, it returns the
Row itself.

Override that in your subclasses of factories if you need to wrap some business code
around the L<DBIx::Class::Row>

=cut

sub wrap{
    my ($self , $o) = @_;
    return $o;
}


=head2 all

Similar to DBIC Resultset all.

Usage:

 my @objs = $this->all();

=cut

sub all{
  my ($self) = @_;
  my $search = $self->search();
  my @res = ();
  while( my $next = $search->next() ){
    push @res , $next;
  }
  return @res;
}

=head2 loop_through

Loop through all the elements of this factory
whilst paging and execute the given code
with the current retrieved object.

WARNINGS:

Make sure your resultset is ordered as
it wouldn't make much sense to page through an unordered resultset.

In case other things are concurrently adding to this resultset, it is possible
that the code you give will be called with the same objects twice.

If it's not the problem and if the rate at which objects are added is
not too fast compared to the processing you are doing in the code, it
should be just fine.

In other cases, you probably want to wrap this in a transaction to have
a frozen view of the resultset.

Usage:

 $this->loop_through(sub{ my $o = shift ; do something with o });
 $this->loop_through(sub{...} , { limit => 1000 }); # Do only 1000 calls to sub.
 $this->loop_through(sub{...} , { rows => 20 }); # Go by pages of 20 rows

=cut

sub loop_through{
  my ($self, $code , $opts ) = @_;

  $opts //= {};
  my $limit = $opts->{limit};
  my $rows = $opts->{rows} // 10;

  # init
  my $page = 1;
  my $search = $self->search(undef , { page => $page , rows => $rows });
  my $last_page = $search->pager->last_page();

  my $ncalls = 0;
  # loop though all pages.
 PAGELOOP:
  while( $page <= $last_page ){
    # Loop through this page
    while( my $o = $search->next() ){
      $code->($o);
      $ncalls++;
      if( $limit && ( $ncalls >= $limit ) ){
        last PAGELOOP;
      }
    }
    # Done with this page.
    # Go to the next one.
    $page++;
    $search = $self->search(undef, { page => $page , rows => $rows });
  }
}

=head2 next

Returns next Business Object from this current DBIx::Resultset.

=cut

sub next{
    my ($self) = @_;
    my $next_o = $self->dbic_rs->next();
    return undef unless $next_o;
    return $self->wrap($next_o);
}

=head2 count

Returns the number of objects in this ResultSet.

=cut

sub count{
    my ($self) = @_;
    return $self->dbic_rs->count();
}


__PACKAGE__->meta->make_immutable();
1;
