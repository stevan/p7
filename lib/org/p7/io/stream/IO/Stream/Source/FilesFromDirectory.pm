
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::core::util qw[ Logging ];

class IO::Stream::Source::FilesFromDirectory :isa(Stream::Source) {
    field $dir :param :reader;

    field $handle;
    field $next;

    ADJUST {
        opendir( $handle, $dir )
            || die "Unable to open $dir because $!";
    }

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        while (true) {
            LOG $self, '... Entering loop ... ' if DEBUG;

            LOG $self, '... About to read directory ...' if DEBUG;
            if ( my $name = readdir( $handle ) ) {

                LOG $self, '... Read directory ...' if DEBUG;
                next unless defined $name;

                LOG $self, '... Got ('.$name.') from directory read ...' if DEBUG;
                next if $name eq '.' || $name eq '..'; # skip these ...

                $next = $dir->child( $name );

                # directory is not readable or has been removed, so skip it
                if ( ! -r $next ) {
                    LOG $self, '... Directory/File not readable ...' if DEBUG;
                    next;
                }
                else {
                    LOG $self, '... Value is good, ready to return it' if DEBUG;
                    return true;
                }
            }
            else {
                LOG $self, '... Exiting loop ... DONE' if DEBUG;
                last;
            }
            LOG $self, '... ... looping' if DEBUG;
        }

        LOG $self, '... Got next value('.$next.')' if DEBUG;
        return false;

    }
}
