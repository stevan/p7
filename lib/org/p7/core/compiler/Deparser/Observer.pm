
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Deparser::Observer {
    method on_next  ($e) { ... }
    method on_error ($e) { ... }
    method on_completed  { ... }
}

class Deparser::Observer::Simple :isa(Deparser::Observer) {
    field $on_next      :param;
    field $on_error     :param;
    field $on_completed :param;

    method on_next  ($e) { $on_next      ? $on_next->($e)    : () }
    method on_error ($e) { $on_error     ? $on_error->($e)   : () }
    method on_completed  { $on_completed ? $on_completed->() : () }
}
