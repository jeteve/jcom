package JCOM::Form;
use Moose;
use Class::MOP;
use JCOM::Form::Field;
use JCOM::Form::Field::String;

=head1 NAME

JCOM::Form - A Moose base class for Form implementation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has 'fields' => ( isa => 'ArrayRef[JCOM::Form::Field]', is => 'ro' , required => 1 , default => sub{ [] } );
has '_fields_idx' => ( isa => 'HashRef[Int]', is => 'ro' , required => 1, default => sub{ {} } );
has '_field_next_num' => ( isa => 'Int' , is => 'rw' , default => 0 , required => 1 );

=head2 add_field

Usage:

   $this->add_field('field_name');
   $this->add_field('FieldType', 'field_name');
   $this->add_field($field_instance);

=cut

sub add_field{
  my ($self, @rest)  = @_;

  my $field = shift @rest;
  if( ( ref( $field ) // '' ) eq 'HASH' && $field->isa('JCOM::Form::Field') ){
    return $self->_add_field($field);
  }
  if( ref( $field ) ){ confess("Argument $field not supported") ; }

  ## Field is not a ref at this point.
  my $name = shift @rest;
  ## defaut is to be a string.
  unless( $name ){ $name = $field , $field = 'String' ; }

  ## Try to load classes.
  my $ret;
  eval{
    my $f_class = 'JCOM::Form::Field::'.$field ;
    Class::MOP::load_class( $f_class );
    $ret =  $self->_add_field($f_class->new({ form => $self , name => $name  }));
  };
  unless( $@ ){ return $ret; }

  eval{
    iClass::MOP::load_class( $field );
    $ret = $self->_add_field($field->new({ form => $self , name =>  $name  }));
  };
  unless( $@ ){ return $ret; }

  confess("Class $field is invalid: $@");
}

sub _add_field{
  my ($self , $field ) = @_;
  $field //= '';
  unless( ref($field) && $field->isa('JCOM::Form::Field') ){ confess("Please give a JCOM::Form::Field, not a $field"); }

  if( $self->field($field->name()) ){
    confess("A field named '".$field->name()."' already exists in this form");
  }

  push @{$self->fields()} , $field;
  ## set the index
  $self->_fields_idx->{$field->name()} = $self->_field_next_num();


  $self->_field_next_num($self->_field_next_num() + 1);
  return $field;
}

=head2 field

Get a field by name or undef.

=cut

sub field{
  my ($self, $name) = @_;
  my $idx = $self->_fields_idx->{$name};
  return defined $idx ? $self->fields->[$idx] : undef;
}


=head1 AUTHOR

Jerome Eteve, C<< <jerome.eteve at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jcom-form at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JCOM-Form>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JCOM::Form


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JCOM-Form>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JCOM-Form>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JCOM-Form>

=item * Search CPAN

L<http://search.cpan.org/dist/JCOM-Form/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Jerome Eteve.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

__PACKAGE__->meta->make_immutable();
1; # End of JCOM::Form
