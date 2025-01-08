
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

class Predicate {
    field $f :param :reader;

    method test ($t) { return (!!$f->($t)); }

    method not      { __CLASS__->new( f => sub ($t) { return !(!!$f->($t)) } ) }
    method and ($p) { __CLASS__->new( f => sub ($t) { return (!!$f->($t)) && (!!$p->($t)) } ) }
    method or  ($p) { __CLASS__->new( f => sub ($t) { return (!!$f->($t)) || (!!$p->($t)) } ) }
}
