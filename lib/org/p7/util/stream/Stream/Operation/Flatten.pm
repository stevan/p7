
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Flatten :isa(Stream::Operation::Node) {
    field $source  :param;
    field $flatten :param;

    field $next;
    field @stack;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, flatten => $flatten } if DEBUG;
    }

    method next { LOG $self if DEBUG; shift @stack }

    method has_next {
        LOG $self if DEBUG;
        return true if @stack;
        while ($source->has_next) {
            push @stack => $flatten->apply( $source->next );
            return true if @stack;
        }
        return false;
    }
}
