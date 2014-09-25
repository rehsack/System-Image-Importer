package System::Image::Importer;

use 5.014;
use strict;
use warnings FATAL => 'all';

=head1 NAME

System::Image::Importer - Import System Images

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

    use System::Image::Importer;

    System::Image::Importer->new_with_options;

=cut

use File::Slurp::Tiny qw(read_file write_file);
use File::Spec;
use File::Path;
use JSON ();
use Moo;
use MooX::Options with_config_from_file => 1;

with "System::Image::Importer::Role::Update", "System::Image::Importer::Role::Production";

option directory => (
    is     => "ro",
    doc    => "Specifies directory to import",
    format => "s",
);

has files => (
    is      => "ro",
    default => sub { [qw/hp2 hp2+xbmc/] },
);

has manifest => (
    is       => "lazy",
    init_arg => undef,
    coerce   => sub {
        my $manifest = $_[0];
        1 != scalar keys %{$manifest} and die "manifest must contain precisely one key";

        $manifest;
    }
);

sub _build_manifest
{
    my $self         = shift;
    my $manifest_fn  = File::Spec->catfile( $self->directory, "manifest.json" );
    my $manifest_cnt = read_file($manifest_fn);
    JSON->new->decode($manifest_cnt);
}

sub import_image
{
    my $self = shift;
    -d $self->directory or die "Cannot access import directory at '$self->directory': $!";
    $self->manifest;
}

after import_image => sub {
    # XXX rm_tree $self->directory
};

sub run
{
    my $self = shift;
    $self->import_image;
}

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-system-image-importer at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=System-Image-Importer>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc System::Image::Importer


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=System-Image-Importer>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/System-Image-Importer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/System-Image-Importer>

=item * Search CPAN

L<http://search.cpan.org/dist/System-Image-Importer/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of System::Image::Importer
