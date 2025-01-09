
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Source::FromArray::OfStreams :isa(Stream::Source) {
    field $sources :param;

    field $index = 0;

    ADJUST {
        LOG $self, 'ADJUST', { sources => $sources } if DEBUG;
    }

    method next { LOG $self if DEBUG; $sources->[$index]->next }

    method has_next {
        LOG $self if DEBUG;
        until ($sources->[$index]->has_next) {
            return false if ++$index > $#{$sources};
        }
        return true;
    }
}

