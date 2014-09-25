package System::Image::Importer::Role::Log;

use Moo::Role;
use Class::Load qw(load_class);

# with "MooX::Role::Logger";
with "MooX::Log::Any";

our $VERSION = "0.001";

has _logger => (
    is       => "lazy",
    init_arg => undef
);

sub _build__logger { return shift->log; }

has log_adapter => (
    is       => "ro",
    required => 1,
    trigger  => 1
);

sub _trigger_log_adapter
{
    my ( $self, $opts ) = @_;
    load_class("Log::Any::Adapter")->set( @{$opts} );
}

__PACKAGE__->can("_build__logger_category") and around _build__logger_category => sub { return "" };

1;
