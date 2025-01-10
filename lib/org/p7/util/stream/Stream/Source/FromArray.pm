
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Source::FromArray :isa(Stream::Source) {
    field $array :param :reader;
    field $index = 0;

    ADJUST {
        LOG $self, 'ADJUST', { array => $array } if DEBUG;
    }

    method     next { LOG $self if DEBUG; $array->[$index++]  }
    method has_next { LOG $self if DEBUG; $index < scalar $array->@* }
}
