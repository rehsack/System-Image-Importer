package System::Image::Importer::Role::Update;

use Moo::Role;

use File::Copy;
use File::Slurp::Tiny qw(read_file write_file);
use File::Spec;
use JSON qw();

with "System::Image::Importer::Role::Log";

=head1 NAME

System::Image::Importer::Role::Update - Import system images into update web-dir

=cut

has update => (
    is     => "ro",
    coerce => sub {
        my $new_val = shift;
        $new_val or return;
        $new_val->{directory} or die "missing 'directory' attribute for update settings";
        -f File::Spec->catfile( $new_val->{directory}, "manifest.json" ) or die "Cannot access update main manifest";
        $new_val;
    },
    predicate => 1,
);

around import_image => sub {
    my $next = shift;
    my $self = shift;
    $self->$next(@_);

    $self->has_update or return;

    my $update_manifest_fn = File::Spec->catfile( $self->update->{directory}, "manifest.json" );
    my $update_manifest = JSON->new->decode( read_file($update_manifest_fn) );

    my ($update) = keys %{ $self->manifest };
    foreach my $file ( @{ $self->files } )
    {
        my ($fn_base) = ( split( ";", $self->manifest->{$update}->{$file} ) );
        my $src_fn    = File::Spec->catfile( $self->directory,           $fn_base );
        my $target_fn = File::Spec->catfile( $self->update->{directory}, $fn_base );
        -f $src_fn or return $self->_logger->emergency("Cannot access $src_fn: $!");
        -f $target_fn and return $self->_logger->emergency("$target_fn already exists");
        copy( $src_fn, $target_fn ) or return $self->_logger->emergency("Copying $src_fn -> $target_fn fails: $!");
    }

    $update_manifest->{$update} = $self->manifest->{$update};

    write_file( $update_manifest_fn, JSON->new->pretty->allow_nonref->encode($update_manifest) );
};

1;
