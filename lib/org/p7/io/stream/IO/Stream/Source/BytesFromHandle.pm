
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::io::stream ];

use org::p7::core::util qw[ Logging ];

class IO::Stream::Source::BytesFromHandle :isa(Stream::Source) {
    field $fh   :param :reader;
    field $size :param :reader = 1;

    field $next;

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        my $result = sysread( $fh, $next, $size );
        return false if $result == 0;
        return true;
    }
}
