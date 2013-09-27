package JCOM::BM;

use warnings;
use strict;

=head1 NAME

JCOM::BM - Business model helpers

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';


=head1 MODULES

=head2 DBICWrapper

Wrap a DBIC Schema with your business model. See L<JCOM::BM::DBICWrapper>

=head2 KVPairs

Expose a simple Key Value source from various sources.

See L<JCOM::BM::KVPairs> and its subclasses.

=head2 Sequence

An simple sequence object

See L<JCOM::BM::Sequence> for details

=head1 AUTHOR

Jerome Eteve, C<< <jerome.eteve at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jcom-bm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JCOM-BM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JCOM::BM


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JCOM-BM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JCOM-BM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JCOM-BM>

=item * Search CPAN

L<http://search.cpan.org/dist/JCOM-BM/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Jerome Eteve.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of JCOM::BM
