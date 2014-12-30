package HTML::FormatNroffSub;

=head1 NAME

HTML::FormatNroffSub - Test package for testing subclassing of HTML::FormatNroff

=head1 SYNOPSIS

 require HTML::FormatNroffSub;
 use HTML::Parse;
 $html = parse_html("<P><TABLE><TR><TD>1</TD></TR></TABLE>");
 $formatter = new HTML::FormatNroffSub(name => 'test', 
                                       project => 'proj') ;
 print $formatter->format($html);

=head1 DESCRIPTION

This is simply a test that HTML::FormatNroff may be subclassed and will
still work.

=cut

require 5.004;

require HTML::FormatNroff;

@ISA = qw(HTML::FormatNroff);

=head1 COPYRIGHT

Copyright (c) 1997 Frederick Hirsch. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Frederick Hirsch <f.hirsch@opengroup.org>

=cut 

1;
