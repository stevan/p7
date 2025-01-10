
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

use org::p7::core::util qw[ Logging ];

class Supplier {
    field $f :param :reader;

    method get { LOG $self if DEBUG; return $f->(); }
}
