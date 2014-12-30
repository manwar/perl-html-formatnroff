package HTML::FormatNroff;

use strict;
use warnings;
use 5.004;
use parent 'HTML::Formatter';

use HTML::Formatter;
use HTML::FormatTableNroff;

sub default_values {
    (
        name          => "",      # man page name
        section       => 1,       # section of manual
        man_date      => "",      # date for section
        project       => "",      # name of project
        tables        => [],
        fonts         => [],
        current_table => undef,
        ignore        => 0,
        man_header    => 1,
        page_width    => "6",
        divs          => [],
    );
}

sub dt_start {
    my ($self) = @_;

    $self->vspace(1);
    $self->textout( "\n.ti +" . $self->{'lm'} . "\n " );
    1;
}

sub dd_start {
    my ($self) = @_;

    $self->adjust_lm(+6);
    $self->vspace(0);
    $self->textout( "\n.ti +" . $self->{'lm'} . "\n " );
    1;
}

sub configure {
    my ( $self, $arg ) = @_;

    my $key;
    foreach $key ( keys %$arg ) {
        $self->{$key} = $$arg{$key};
    }
    $self;
}

sub begin {
    my $self = shift;
    $self->HTML::Formatter::begin;
    $self->{lm} = 0;
}

sub end {
    shift->collect("\n");
}

sub html_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    unless ( $self->{man_header} ) { return 1; }

    unless ( $self->{man_date} ) {
        my ( $sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $isdst ) =
          localtime();
        my $this_mon = (
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        )[$mon];
        $self->{man_date} = "$mday" . " $this_mon" . " $year";
    }

    $self->out( ".TH \""
          . $self->{name} . "\" \""
          . $self->{section} . "\" \""
          . $self->{man_date} . "\" \""
          . $self->{project}
          . "\"" );
    1;
}

sub font_start {
    my ( $self, $font ) = @_;

    push( @{ $self->{'fonts'} }, $font );

    $self->textout( '\f' . "$font" );
}

sub font_end {
    my ($self) = @_;

    pop( @{ $self->{'fonts'} } );

    my $font = pop( @{ $self->{'fonts'} } );
    push( @{ $self->{'fonts'} }, $font );

    unless ($font) {
        $font = 'R';
    }
    $self->textout( '\f' . "$font" );
}

sub i_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->font_start('I');
}

sub i_end {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->font_end();
}

sub b_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->font_start('B');
    1;
}

sub b_end {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->font_end();
}

sub table_start {
    my ( $self, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    if ( defined( $self->{'current_table'} ) ) {
        push( @{ $self->{'tables'} }, $self->{'current_table'} );
    }

    my %attr = ( page_width => $self->{'page_width'}, );

    for (qw{align width}) {
        $attr{$_} = lc( $node->attr('$_') ) if defined $node->attr('$_');
    }

    unless ( $node->attr('align') ) {
        if ( $self->{'center'} ) {
            $attr{align} = 'center';
        }
    }

    $self->{'current_table'} = new HTML::FormatTableNroff( $self, %attr );
}

sub tr_start {
    my ( $self, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    my %attr = ();

    for (qw{align width}) {
        $attr{$_} = lc( $node->attr('$_') ) if defined $node->attr('$_');
    }

    $self->{'current_table'}->add_row(%attr);
}

sub tr_end {
    my ($self) = @_;
}

sub a_start {
    my ($self) = @_;
}

sub a_end {
    my ($self) = @_;
}

sub td_start {
    my ( $self, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    $self->start_data($node);
}

sub td_end {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->{'current_table'}->end_data();
}

sub th_start {
    my ( $self, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    $self->start_data( $node, 'header' );
}

# internal helping routine for processing table cells

sub start_data {
    my ( $self, $node, $header ) = @_;

    if ( $self->{ignore} ) { return 1; }

    my %attr = ( header => $header, );

    for (qw{align valign nowrap rowspan colspan}) {
        $attr{$_} = lc( $node->attr('$_') ) if defined $node->attr('$_');
    }

    $self->{'current_table'}->start_data(%attr);
}

sub th_end {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->{'current_table'}->end_data();
}

sub table_end {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->{'current_table'}->output();
    $self->{'current_table'} = pop( @{ $self->{'tables'} } );
}

sub p_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->textout("\n.PP\n");

}

sub p_end {
    my $self = shift;

}

sub goto_lm {
}

sub br_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->textout("\n.br\n");
}

sub hr_start {
    my $self = shift;

    if ( $self->{ignore} ) { return 1; }

    $self->textout("\n.br\n.ta 6.5i\n.tc _\n\t\n.br\n");
}

sub header_start {
    my ( $self, $level, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    $self->textout("\n.SH ");
    1;
}

sub header_end {
    my ( $self, $level, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    $self->textout("\n");
    1;
}

sub out {
    my $self = shift;
    my $text = shift;

    if ( $self->{ignore} ) { return 1; }

    if ( defined $self->{vspace} ) {
        $self->nl( $self->{vspace} );
        $self->{vspace} = undef;
    }

    if ($text) {
        $self->collect($text);
    }
}

sub pre_out {
    my ( $self, $pre ) = @_;

    if ( $self->{ignore} ) { return 1; }

    if ( defined $self->{vspace} ) {
        $self->nl( $self->{vspace} );
        $self->{vspace} = undef;
    }
    my $indent = ' ' x $self->{lm};
    $pre =~ s/^/$indent/mg;
    $self->collect($pre);
    $self->{'out'}++;
}

sub nl {
    my ( $self, $cnt ) = @_;

    if ( $self->{ignore} ) { return 1; }

    $self->collect("\n.sp $cnt\n");
    $self->{'out'}++;
}

sub adjust_lm {
    my ( $self, $indent ) = @_;

    $self->{lm} += $indent;
}

sub adjust_rm {
    my $self = shift;
}

sub bullet {
    my ( $self, $tag ) = @_;

    if ( $self->{'lm'} > 0 ) {
        $self->textout( "\n.ti +" . $self->{'lm'} . "\n$tag " );
    }
}

sub textflow {
    my ( $self, $node ) = @_;

    if ( $self->{ignore} ) { return 1; }

    if ( ( !defined( $self->{'current_table'} ) )
        and $self->{'center'} ) {
        $self->textout("\n.ce\n");
    }
    if ( $self->{'underline'} ) {
        $self->textout("\n.ul\n");
    }

    if ( $self->{'lm'} > 0 ) {
        my $repl = "\n.ti +" . $self->{'lm'} . "\n ";
        $node =~ s/\n/$repl/;
    }

    if ( defined( $self->{'current_table'} ) ) {

        $self->{'current_table'}->add_text($node)
          or $self->SUPER::textflow($node);
    }
    else {
        $self->SUPER::textflow($node);
    }
}

sub textout {
    my ( $self, $text ) = @_;

    if ( $self->{ignore} ) { return 1; }

    if ( defined( $self->{'current_table'} ) ) {
        $self->{'current_table'}->add_text($text)
          || $self->out($text);
    }
    else {
        $self->out($text);
    }
}

sub blockquote_start {
    my ( $self, $node ) = @_;

    $self->textout("\n.PP\n.in +5\n");
}

sub blockquote_end {
    my ( $self, $node ) = @_;

    $self->textout("\n.in -5\n.PP\n");
}

# all the push/pop is so we can safely ignore nested divs.

sub div_start {
    my ( $self, $node ) = @_;

    my $type = lc $node->attr('type');

    push( @{ $self->{'divs'} }, $type );

    if ( $type =~ /nroff_ignore/ ) {
        $self->{'ignore'} = 1;
    }
}

sub div_end {
    my ( $self, $node ) = @_;

    my $type = pop( @{ $self->{'divs'} } );

    if ( $type =~ /nroff_ignore/ ) {
        $self->{ignore} = 0;
    }
}

sub meta_start {
    my ( $self, $node ) = @_;

    my $meta_name = lc $node->attr('NAME');
    unless ( $meta_name eq 'nroff-control' ) {
        return 1;
    }
    my $meta_content = lc $node->attr('CONTENT');

    if ( $meta_content eq 'ignore_start' ) {
        $self->{'ignore'} = 1;
    }
    else {
        $self->{'ignore'} = 0;
    }
}

1;

__END__

=pod

=head1 NAME

HTML::FormatNroff - Format HTML as nroff man page

=head1 SYNOPSIS

    use HTML::FormatNroff;
    my $html = parse_htmlfile("test.html");
    my $formatter = HTML::FormatNroff->new(name => 'trial', project => 'MyProject');
    print $formatter->format($html);

=head1 DESCRIPTION

The HTML::FormatNroff is a formatter that outputs nroff source
for the nroff text processor, using man macros, and tbl commands for table
processing.

The result of using the formatter must be processed as follows, when directing
output to the screen (assume output is in the file "text.nroff"):

    tbl -TX text.nroff | nroff -man | col

If the output is to be printed, on an laser printer for example, a command
similar to the following must be used:

    tbl -TX text.nroff | nroff -man -Tlj | lpr

Meta tags may be placed in the HTML so that portions of the HTML
will be ignored and not processed. Content between the tags

    <META NAME="nroff-control" CONTENT="ignore_start">
    <META NAME="nroff-control" CONTENT="ignore_end">

will be ignored. In the BODY META is not supported, but DIV may be used
as follows:

    <DIV TYPE="NROFF_IGNORE">
    </DIV>

In both the META and DIV uses, case is ignored.

=head1 METHODS

=head2 $format_nroff->dt_start();

Start a definition term <DT>,
using a temporary indent and vertical space.

=head2 $format_nroff->dd_start();

Start a data definition, <DD>, using a temporary indent.

=head2 $format_nroff->configure($arg);

Configure the nroff formatter, setting the attributes passed in the
$arg attribute (hash reference)

=head2 $format_nroff->begin();

Begin HTML formatting.

=head2 $format_nroff->end();

End HTML formatting.

=head2 $format_nroff->html_start();

Process <HTML> start tag. Create the man page header based
on saved attributes, unless the attribute
$format_nroff->{'man_header'} is not set. This generates the following header:

    .TH "name" section "date" "project"

=head2 $format_nroff->font_start($font);

Start the font specified by the $font character (e.g. B, or I).
The font is remembered so nested fonts are handled correctly.

=head2 $format_nroff->font_end();

End the current font, returning to the previous one.

=head2 $format_nroff->i_start();

Process <I> tag.

=head2 $format_nroff->i_end();

Process </I> tag.

=head2 $format_nroff->b_start();

Process <B> tag.

=head2 $format_nroff->b_end();

Process </B> tag.

=head2 $format_nroff->table_start($node);

Process <TABLE>, start table processing. $node
is the current html_parser node.

    Pass on the $format_nroff->{'page_width'} to FormatTableNroff

=head2 $format_nroff->tr_start($node);

Process <TR>, add table row.

=head2 $format_nroff->tr_end();

End the table row </TR>

=head2 $format_nroff->a_start();

<A> is ignored.

=head2 $format_nroff->a_end();

</A> is ignored.

=head2 $format_nroff->td_start($node);

Process <TD>, add table cell

=head2 $format_nroff->td_end();

Process </TD>, end table cell

=head2 $format_nroff->th_start($node);

Process <TH>, add table header cell

=head2 $format_nroff->th_end();

Process </TH>, end table header cell

=head2 $format_nroff->table_end();

Process </TABLE>. Actually output entire table.

=head2 $format_nroff->p_start();

Process <P>.

=head2 $format_nroff->p_end();

Process </P> by doing nothing.

=head2 $format_nroff->goto_lm()

goto_lm does nothing.

=head2 $format_nroff->br_start();

Process <BR>.

=head2 $format_nroff->hr_start();

Process <HR>

=head2 $format_nroff->header_start();

Process <H?> simply using .SH

=head2 $format_nroff->header_end();

Process </H?> simply outputing newline

=head2 $format_nroff->out($text);

Output text.

=head2 $format_nroff->pre_out($pre);

Output <PRE> text.

=head2 $format_nroff->nl($cnt);

Output newline.

=head2 $format_nroff->adjust_lm($indent);

adjust indent (left margin)

=head2 $format_nroff->adjust_rm();

not used.

=head2 $format_nroff->bullet($tag);

output the bullet, using a temporary indent and the $tag

=head2 $format_nroff->textflow($node);

Output text or add it to table if currently inside a table
If centered add .ce unless inside a table, if underlined add .ul,
if the left margin is adjusted use a .ti for every new line.

=head2 $format_nroff->blockquote_start($node);

Start <BLOCKQUOTE>, by making a new paragraph, and indenting.

=head2 $format_nroff->blockquote_end($node);

</BLOCKQUOTE>, by ending indent, and making a new paragraph

=head2 $format_nroff->div_start($node);

Process DIV

    <DIV TYPE="NROFF_IGNORE">
        is used to ignore all subsequent content until the next
    </DIV>

This allows HTML to be used which is not to be converted to HTML
(such as navigation controls). Case is ignored in the type.

In the header you probably should use

    <META NAME="nroff-control" CONTENT="ignore_start">
        is used to ignore all subsequent content until the next
    <META NAME="nroff-control" CONTENT="ignore_end">

=head2 $format_nroff->meta_start($node);

Process <META> tag.

    <META NAME="nroff-control" CONTENT="ignore_start">
        is used to ignore all subsequent content until the next
    <META NAME="nroff-control" CONTENT="ignore_end">

This allows HTML to be used which is not to be converted to HTML
(such as navigation controls). Case is ignored.

Strictly speaking META is only allowed in the HTML HEAD, so this
META. In the body, you should use:

    <DIV TYPE="NROFF_IGNORE">
    </DIV>

=head1 SEE ALSO

L<HTML::Formatter>,
L<HTML::FormatTableCell>,
L<HTML::FormatTableCellNroff>,
L<HTML::FormatTableNroff>,
L<HTML::FormatTableRow>,
L<HTML::FormatTableRowNroff>

=head1 COPYRIGHT

Copyright (c) 1997 Frederick Hirsch. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHORS

Frederick Hirsch <f.hirsch@opengroup.org>

Stefan G. <minimal@cpan.org>

=cut