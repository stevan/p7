
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Source::FromSupplier :isa(Stream::Source) {
    field $supplier :param :reader;

    ADJUST {
        LOG $self, 'ADJUST', { supplier => $supplier } if DEBUG;
    }

    method next { LOG $self if DEBUG; $supplier->get }
    method has_next { LOG $self if DEBUG; true }
}
