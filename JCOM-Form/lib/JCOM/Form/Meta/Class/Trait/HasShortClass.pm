package JCOM::Form::Meta::Class::Trait::HasShortClass;
use Moose::Role;

has 'short_class' => ( is => 'rw' , isa => 'Str'
                       # default => sub{ my $sn = shift->name();
                       #                 $sn =~ s/JCOM::Form::Field:://;
                       #                 return $sn;
                       #               }
                     );
1;
