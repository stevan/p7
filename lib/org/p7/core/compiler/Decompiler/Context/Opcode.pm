
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Decompiler::Context::Opcode {
    use overload '""' => \&to_string;

    field $stack     :param :reader;
    field $statement :param :reader;
    field $op        :param :reader;

    field $name    :reader;
    field $depth   :reader;
    field $is_null :reader = false;

    ADJUST {
        $is_null = $op->name eq 'null';
        $name    = $is_null ? substr(B::ppname( $op->targ ), 3) : $op->name;
        $depth   = scalar @$stack;
    }

    ## ---------------------------------------------------------------------------------------------
    ## op stuff
    ## ---------------------------------------------------------------------------------------------

    method type { B::class($op) }
    method addr { ${ $op }  }

    method flags   { $op->flags   }
    method private { $op->private }
    method target  { $op->targ    }

    method has_pad_target { $op->targ > 0 }

    method wants_void         { ($op->flags & B::OPf_WANT) == B::OPf_WANT_VOID   }
    method wants_scalar       { ($op->flags & B::OPf_WANT) == B::OPf_WANT_SCALAR }
    method wants_list         { ($op->flags & B::OPf_WANT) == B::OPf_WANT_LIST   }

    method has_descendents    { $op->flags & B::OPf_KIDS    }
    method was_parenthesized  { $op->flags & B::OPf_PARENS  }
    method return_container   { $op->flags & B::OPf_REF     }
    method is_lvalue          { $op->flags & B::OPf_MOD     }
    method is_mutator_varient { $op->flags & B::OPf_STACKED }
    method is_special         { $op->flags & B::OPf_SPECIAL }

    ## ---------------------------------------------------------------------------------------------
    ## Context stuff
    ## ---------------------------------------------------------------------------------------------

    method parent { $stack->[-1] }

    method is_child  ($o) { $self->addr == $o->parent->addr }
    method is_parent ($o) { !($self->parent) || ($self->parent->addr == $o->addr) }

    method has_sibling { !! ${ $op->sibling } }

    method is_sibling ($o) {
        ($o->depth == $depth)
            && $self->parent->is_equal_to($o->parent)
    }

    method is_ancestor ($o) {
        ($o->depth > $depth)                       # skip if the depth not greater than us
            && ($o->is_parent($self)               # it is an anscestor if it is our parent
                || $self->parent->is_ancestor($o)) # otherwise, check our parent
    }

    method is_descendant ($o) {
        ($o->depth < $depth)                          # skip if the depth is less than us
            && ($o->is_child($self)                   # it is a descendant if it is our child
                || $self->is_descendant($op->parent)) # otherwise, check their parent
    }

    method is_equal_to ($other) { $self->addr == $other->addr }

    method to_string {
        sprintf '%s%s[%s](%d)' => ($is_null ? '~' : ''), $self->type, $self->name, $self->addr;
    }
}
