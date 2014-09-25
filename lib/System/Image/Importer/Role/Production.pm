package System::Image::Importer::Role::Production;

use Moo::Role;

use File::Copy;
use File::Glob;
use File::Path qw(make_path remove_tree);
use File::Spec;

with "System::Image::Importer::Role::Log";

=head1 NAME

System::Image::Importer::Role::Production - Import system images into production service

=cut

has production => (
    is     => "ro",
    coerce => sub {
        my $new_val = shift;
        $new_val              or return;
        $new_val->{directory} or die "missing 'directory' attribute for production settings";
        $new_val->{file}      or die "missing 'file' attribute for production settings";
        $new_val;
    },
    predicate => 1,
);

around import_image => sub {
    my $next = shift;
    my $self = shift;
    $self->$next(@_);

    $self->has_production or return;

    my ($update) = keys %{ $self->manifest };
    my ($fn_base) = ( split( ";", $self->manifest->{$update}->{ $self->production->{file} } ) );
    ( my $dir_base = $fn_base ) =~ s/\.[^\.]*$//;

    if ( -d $self->production->{directory} )
    {
        foreach my $dir_entry ( glob( File::Spec->catfile( $self->production->{directory}, "*" ) ) )
        {
            remove_tree($dir_entry);
        }
    }

    my $target_dir = File::Spec->catfile( $self->production->{directory}, $dir_base );
    my $src_fn = File::Spec->catfile( $self->directory, $fn_base );
    make_path($target_dir);
    system("cd $target_dir && tar xjf $src_fn");
    if ( "ARRAY" eq ref $self->production->{also} )
    {
        foreach my $fn ( @{ $self->production->{also} } )
        {
            copy( File::Spec->catfile( $self->directory, $fn ), $self->production->{directory} );
        }
    }
};

1;
