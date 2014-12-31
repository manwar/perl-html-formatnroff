package HTML::FormatNroff::Table;

use 5.004;
use strict;
use warnings;
use Carp;

sub new {
    my ( $class, $formatter, %attr ) = @_;

    my $self = bless {
        formatter     => $formatter,
        align         => $attr{'align'} || 'left',
        width         => $attr{'width'},
        page_width    => $attr{'page_width'},
        tab           => '%',
        border        => 1,
        previous_rows => [],
        current_row   => undef,
        data          => [],
    }, $class;

    return $self;
}

sub end_row {
    my ($self) = @_;

    $self->{"current_row"} = pop( @{ $self->{'previous_rows'} } );
}

sub start_data {
    my ( $self, %attr ) = @_;

    $self->{"current_row"}->add_element(%attr);
}

sub end_data {
    my ($self) = @_;

    $self->{"current_row"}->end_element();
}

sub add_text {
    my ( $self, $text ) = @_;

    if ( defined( $self->{"current_row"} )
        && $self->{"current_row"} ne "" ) {
        $self->{"current_row"}->add_text($text);
    }
    else {
        return 0;
    }
}

1;

__END__

=pod

=head1 NAME

HTML::FormatNroff::Table - base class for formatting HTML Tables

=head1 SYNOPSIS

 require HTML::FormatNroff::Table;
 @ISA = qw(HTML::FormatNroff::Table);

=head1 DESCRIPTION

The HTML::FormatNroff::Table is a base class for formatting HTML tables.
It is used by a class such as HTML::FormatTableNroff, which is called by
the formatter HTML::FormatNroff when tables are processed.

=head1 METHODS

=head2 $table = new HTML::FormatNroff::Table($formatter, %attr);

Create new table representation. Formatter is used to output
table (e.g. $formatter is C<HTML::FormatNroff>)

Attributes include

 align: table alignment (default is 'left'),
 tab: the character used in tbl to separate table cells.
       (the default is '%', and should be a character not included
        in table text)
 page_width: the page width in inches (e.g. "6")
 width: width of table, string including the percent (eg "100%")

=head2 $table->end_row();

End the current table row.

=head2 $table->start_data(%attr);

Start new table cell.

=head2 $table->end_data();

End table cell.

=head2 $table->add_text($text);

Add text to table

=head2 $table->output();

Output the table - must be overridden by subclass.

=cut

sub output {
    croak "FormatTable::out must be overridden\n";
}

=head1 SEE ALSO

L<HTML::Formatter>

L<HTML::FormatNroff>

=head1 COPYRIGHT

Copyright (c) 1997 Frederick Hirsch. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Frederick Hirsch <f.hirsch@opengroup.org>

=cut
