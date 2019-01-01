

Enumeration of standard headers



Role for defining all header objects

### method prepared-values

```perl6
method prepared-values() returns Mu
```

Convert objects stored into appropriately formatted strings

### method value

```perl6
method value() returns Mu
```

Treat the values of this header as a single value

### method primary

```perl6
method primary() returns Mu
```

Retrieve the primary value out of the header value

### method params

```perl6
method params() returns Mu
```

Retrieve all the parameters associated with this header value

### method set-param

```perl6
method set-param(
    $name,
    $new-value
) returns Mu
```

Set a header value on the string (this is semi-internal)

### method param

```perl6
method param(
    $name
) returns Mu
```

Read/write a parameter set within a value

### method AT-POS

```perl6
method AT-POS(
    $index
) returns Mu
```

Read the individual values as an array lookup

### method key

```perl6
method key() returns Str
```

The header lookup key

### method push

```perl6
method push(
    *@values
) returns Mu
```

Push values into the header

### method unshift

```perl6
method unshift(
    *@values
) returns Mu
```

Unshift values into the header

### method shift

```perl6
method shift() returns Mu
```

Shift values off the header

### method pop

```perl6
method pop() returns Mu
```

Pop values off the header

### method init

```perl6
method init(
    *@values
) returns Mu
```

Set the given values only if the header has none already

### method remove

```perl6
method remove() returns Mu
```

Remove all values from this header

### method as-string

```perl6
method as-string(
    Str :$eol = "\n"
) returns Mu
```

Output the header in Name: Value form for each value

### method Bool

```perl6
method Bool() returns Mu
```

True if this header has values

### method Str

```perl6
method Str() returns Mu
```

Same as calling .value

### method Int

```perl6
method Int() returns Mu
```

Treat the whole value as an Int

### method Numeric

```perl6
method Numeric() returns Mu
```

Treat the whole value as Numeric

### method list

```perl6
method list() returns Mu
```

Same as calling .prepared-values

class HTTP::Header::Standard
----------------------------

A standard header definition



A Content-Type header definition

### method charset

```perl6
method charset() returns Mu
```

Read or write the charset parameter

class HTTP::Header::Custom
--------------------------

A custom header definition

### multi method new

```perl6
multi method new(
    @headers,
    Bool :$quiet = Bool::False
) returns Mu
```

Initialze headers with a list of pairs

### multi method new

```perl6
multi method new(
    %headers,
    Bool :$quiet = Bool::False
) returns Mu
```

Initialize headers with an array

### multi method new

```perl6
multi method new(
    Bool :$quiet = Bool::False,
    *@headers,
    *%headers
) returns Mu
```

Initialize headers empty or with a slurpy list of pairs or a slurpy hash

### multi method headers

```perl6
multi method headers(
    @headers
) returns Mu
```

Set multiple headers from a list of pairs

### multi method headers

```perl6
multi method headers(
    %headers
) returns Mu
```

Set multiple headers from a hash

### multi method headers

```perl6
multi method headers(
    *@headers,
    *%headers
) returns Mu
```

Set multiple headers from a slurpy list of pairs or slurpy hash

### method build-header

```perl6
method build-header(
    $name,
    *@values
) returns HTTP::Header
```

Helper for building header objects

### method elems

```perl6
method elems() returns Mu
```

Returns the number of headers set

### method list

```perl6
method list() returns Mu
```

Returns the headers as a sorted list

### method clone

```perl6
method clone() returns Mu
```

Performs a safe deep clone of the headers

### method header-proxy

```perl6
method header-proxy(
    $name
) returns Mu
```

Helper for use by .header()

### multi method header

```perl6
multi method header(
    Standard::Name $name
) returns HTTP::Header
```

Read or write a standard header

### multi method header

```perl6
multi method header(
    Str $name,
    :$quiet = Bool::False
) returns HTTP::Header
```

Read or write a custom header

### multi method remove-header

```perl6
multi method remove-header(
    $name
) returns Mu
```

Remove a header

### multi method remove-header

```perl6
multi method remove-header(
    *@names
) returns Mu
```

Remove more than one header

### method remove-content-headers

```perl6
method remove-content-headers() returns Mu
```

Remove all the entity and Content-* headers

### method clear

```perl6
method clear() returns Mu
```

Remove all headers

### method vacuum

```perl6
method vacuum() returns Mu
```

Clean up header objects that have no values

### method sorted-headers

```perl6
method sorted-headers() returns Mu
```

Return the headers as a sorted list

### method flatmap

```perl6
method flatmap(
    &code
) returns Mu
```

Iterate over the headers in sorted order

### method as-string

```perl6
method as-string(
    Str :$eol = "\n"
) returns Mu
```

Output the headers as a string in sorted order

### method for-PSGI

```perl6
method for-PSGI() returns Mu
```

Return the headers as a list of Pairs for use with PSGI

