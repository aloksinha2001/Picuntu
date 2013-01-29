# -*- cperl -*-
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Copyright (C) 2002-2011 Jens Thoms Toerring <jt@toerring.de>


package File::FcntlLock;

use 5.006;
use strict;
use warnings;
use POSIX;
use Errno;
use Carp;

require Exporter;
require DynaLoader;

our @ISA = qw( Exporter DynaLoader );

# Items to export into callers namespace by default.

our @EXPORT = qw( F_GETLK F_SETLK F_SETLKW
                  F_RDLCK F_WRLCK F_UNLCK
                  SEEK_SET SEEK_CUR SEEK_END );

our $VERSION = '0.14';


=pod

=head1 NAME

File::FcntlLock - File locking with L<fcntl(2)>

=head1 SYNOPSIS

  use File::FcntlLock;

  my $fs = new File::FcntlLock;
  $fs->l_type( F_RDLCK );
  $fs->l_whence( SEEK_CUR );
  $fs->l_start( 100 );
  $fs->l_len( 123 );

  open my $fh, '<', 'file_name' or die "Can't open file: $!\n";
  $fs->lock( $fh, F_SETLK )
      or print "Locking failed: " . $fs->error . "\n";
  $fs->l_type( F_UNLCK );
  $fs->lock( $fh, F_SETLK )
      or print "Unlocking failed: " . $fs->error . "\n";

=head1 DESCRIPTION

File locking in Perl is usually done using the L<flock()> function.
Unfortunately, this only allows locks on whole files and is often
implemented in terms of L<flock(2)>, which has some shortcomings.

Using this module file locking via L<fcntl(2)> can be done (obviously,
this restricts the use of the module to systems that have a L<fcntl(2)>
system call). Before a file (or parts of a file) can be locked, an
object simulating a flock structure must be created and its properties
set. Afterwards, by calling the C<lock()> method a lock can be set or it
can be determined if and which process currently holds the lock.

=cut

# Set up a hash with the error messages, but only for errno's that Errno
# knows about. The texts represent what's written in SUSv3 and in the man
# pages for Linux, TRUE64, OpenBSD3 and Solaris8.

my %fcntl_error_texts;

BEGIN {
    my $err;

    if ( $err = eval { &Errno::EACCES } ) {
        $fcntl_error_texts{ $err } = "File or segment already locked " .
                                     "by other process(es) or file is " .
                                     "mmap()ed to virtual memory";
    }
    if ( $err = eval { &Errno::EAGAIN } ) {
        $fcntl_error_texts{ $err } = "File or segment already locked " .
                                     "by other process(es)";
    }
    if ( $err = eval { &Errno::EBADF } ) {
        $fcntl_error_texts{ $err } = "Not an open file handle or descriptor " .
                                     "or not open for writing (with F_WRLCK)" .
                                     " or reading (with F_RDLCK)";
    }
    if ( $err = eval { &Errno::EDEADLK } ) {
        $fcntl_error_texts{ $err } = "Operation would cause a deadlock";
    }
    if ( $err = eval { &Errno::EFAULT } ) {
        $fcntl_error_texts{ $err } = "Lock outside accessible address space " .
                                     "or to many locked regions";
    }
    if ( $err = eval { &Errno::EINTR } ) {
        $fcntl_error_texts{ $err } = "Operation interrupted by a signal";
    }
    if ( $err = eval { &Errno::ENOLCK } ) {
        $fcntl_error_texts{ $err } = "Too many segment locks open, lock " .
                                     "table full or remote locking protocol " .
                                     "failure (e.g. NFS)";
    }
    if ( $err = eval { &Errno::EINVAL } ) {
        $fcntl_error_texts{ $err } = "Illegal parameter or file does not " .
                                     "support locking";
    }
    if ( $err = eval { &Errno::EOVERFLOW } ) {
        $fcntl_error_texts{ $err } = "One of the parameters to be returned " .
                                     "can not be represented correctly";
    }
    if ( $err = eval { &Errno::ENETUNREACH } ) {
        $fcntl_error_texts{ $err } = "File is on remote machine that can " .
                                     "not be reached anymore";
    }
    if ( $err = eval { &Errno::ENOLINK } ) {
        $fcntl_error_texts{ $err } = "File is on remote machine that can " .
                                     "not be reached anymore";
    }
}


bootstrap File::FcntlLock $VERSION;


###########################################################

=pod

To create a new object representing a flock structure call C<new()>:

  $fs = new File::FcntlLock;

You also can pass the C<new()> method a set of key-value pairs to
initialize the objects properties, e.g. use

  $fs = new File::FcntlLock l_type   => F_WRLCK,
                            l_whence => SEEK_SET,
                            l_start  => 0,
                            l_len    => 100;

if you plan to obtain a write lock for the first 100 bytes of a file.

=cut

sub new {
    my $inv = shift;
    my $pkg = ref( $inv ) || $inv;

    my $self = { l_type        => F_RDLCK,
                 l_whence      => SEEK_SET,
                 l_start       => 0,
                 l_len         => 0,
                 l_pid         => 0,
                 errno         => undef,
                 error_message => undef      };

    if ( @_ % 2 ) {
        carp "Missing value in key-value initializer list " .
             "in call of new method";
        return;
    }

    while ( @_ ) {
        my $key = shift;
        no strict 'refs';
        unless ( defined &$key ) {
            carp "Flock structure has no '$key' member " .
                 "in call of new method";
            return;
        }
        &$key( $self, shift );
        use strict 'refs';
    }

    bless $self, $pkg;
}


###########################################################

=pod

Once you have created the object simulating the flock structure
the following methods allow to query and in most cases also to
modify the properties of the object.

=over 4

=item C<l_type()>

If called without an argument returns the current setting of the
lock type, otherwise the lock type is set to the argument, which
must be either C<F_RDLCK>, C<F_WRLCK> or C<F_UNLCK> (for read lock,
write lock or unlock).

=cut

sub l_type {
    my $flock_struct = shift;

    if ( @_ ) {
        my $l_type = shift;
        unless (    $l_type == F_RDLCK
                 or $l_type == F_WRLCK
                 or $l_type == F_UNLCK ) {
            carp "Invalid argument in call of l_type method";
            return;
        }
        $flock_struct->{ l_type } = $l_type;
    }
    return $flock_struct->{ l_type };
}


###########################################################

=pod

=item C<l_whence()>

Queries or sets the C<l_whence> property of the flock object,
determining if the C<l_start> value is relative to the start of
the file, to the current position in the file or to the end of
the file. The corresponding values are C<SEEK_SET>, C<SEEK_CUR>
and C<SEEK_END>. See also the man page for L<lseek(2)>.

=cut

sub l_whence {
    my $flock_struct = shift;

    if ( @_ ) {
        my $l_whence = shift;
        unless (    $l_whence == SEEK_SET
                 or $l_whence == SEEK_CUR
                 or $l_whence == SEEK_END ) {
            carp "Invalid argument in call of l_whence method";
            return;
        }
        $flock_struct->{ l_whence } = $l_whence;
    }
    return $flock_struct->{ l_whence };
}


###########################################################

=pod

=item C<l_start()>

Queries or sets the start position (offset) of the lock in the
file according to the mode selected by the C<l_whence> member.
See also the man page for L<lseek(2)>.

=cut

sub l_start {
    my $flock_struct = shift;

    $flock_struct->{ l_start } = shift if @_;
    return $flock_struct->{ l_start };
}


###########################################################

=pod

=item C<l_len()>

Queries or sets the length of the region (in bytes) in the file
to be locked. A value of 0 is interpreted as to mean a lock (starting
at C<l_start>) up to the very end of the file.

According to SUSv3 negative values for C<l_start> are allowed
(resulting in a lock ranging from C<l_start + l_len> to
C<l_start - 1>) Unfortunately, not all systems allow negative
arguments and will return an error when you try to obtain the
lock, so please read the L<fcntl(2)> man page of your system
carefully for details.

=cut

sub l_len {
    my $flock_struct = shift;

    $flock_struct->{ l_len } = shift if @_;
    return $flock_struct->{ l_len };
}


###########################################################

=pod

=item C<l_pid()>

This method allows retrieving the PID of a process currently
holding the lock after a call of C<lock()> with C<F_SETLK> indicated
that another process is holding the lock. A call to C<lock()>
with C<F_GETLK> will fill in this value so C<l_pid()> can be called.

=back

=cut

sub l_pid {
    return shift->{ l_pid };
}


###########################################################

=pod

When not initialized the flock objects C<l_type> property is set
to C<F_RDLCK> by default, C<l_whence> to C<SEEK_SET>, and both
C<l_start> and C<l_len> to 0, i.e. the settings for a read lock
on the whole file.


After having set up the object representing a flock structure you
can determine the current holder of a lock or try to obtain a lock
by invoking the C<lock()> method with two arguments, a file handle
(or a file descriptor, the module figures out automatically what
it got) and a flag indicating the action to be taken, e.g.

  $fs->lock( $fh, F_SETLK );

There are three values that can be used as the second argument:

=over 4

=item C<F_GETLK>

For C<F_GETLK> the C<lock()> method determines if and who currently
is holding the lock.  If no other process is holding the lock the
C<l_type> field is set to C<F_UNLCK>. Otherwise the flock structure
object is set to the values that prevent us from obtaining a lock.
There may be multiple such blocking processes, including some that
are themselves blocked waiting to obtain a lock. C<F_GETLK> will
only make details of one of these visible, and one has no control
over which process this is.

=item C<F_SETLK>

For C<F_SETLK> the C<lock()> method tries to obtain the lock (when
C<l_type> is set to either C<F_WRLCK> or C<F_RDLCK>) or releases
the lock (if C<l_type> is set to C<F_UNLCK>). If a lock is held
by some other process the method call returns C<undef> and errno
is set to C<EACCESS> or C<EAGAIN> (please see the the man page for
L<fcntl(2)> for the details).

=item C<F_SETLKW>

is similar to C<F_SETLK> but instead of returning an error if the
lock can't be obtained immediately it blocks until the lock is
obtained. If a signal is received while waiting for the lock the
method returns C<undef> and errno is set to C<EINTR>.

=back

On success the method returns the string "0 but true". If the
method fails (as indicated by an C<undef> return value) you can
either immediately evaluate the error number (usingf $!, $ERRNO
or $OS_ERROR) or check for it at some later time via the methods
discussed below.

=cut

sub lock {
    my ( $flock_struct, $fh, $action ) = @_;
    my ( $ret, $err );

    # Figure out the file descriptor - we might get a file handle, a
    # typeglob or already a file descriptor) and set it to a value which
    # will make fcntl(2) fail with EBADF if the argument is undefined or
    # is a file handle that's invalid.

    my $fd = ( ref( $fh ) or $fh =~ /^\*/ ) ? fileno( $fh ) : $fh;
    $fd = -1 unless defined $fd;

    # Set the action argument to something invalid if it's not defined
    # which then fcntl(2) fails and errno gets set accordingly

    $action = -1 unless defined $action;

    if ( $ret = C_fcntl_lock( $fd, $action, $flock_struct, $err ) ) {
        $flock_struct->{ errno } = $flock_struct->{ error } = undef;
    } elsif ( $err ) {
        die "Internal error in File::FcntlLock module detected";
    } else {
        $flock_struct->{ errno } = $! + 0;
        $flock_struct->{ error } = defined $fcntl_error_texts{ $! + 0 } ?
                         $fcntl_error_texts{ $! + 0 } : "Unexpected error: $!";
    }

    return $ret;
}


###########################################################

=pod

There are three methods for obtaining information about the
reason the the last call of C<lock()> for the object failed:

=over 4

=item C<lock_errno()>

Returns the error number from the latest call of C<lock()>. If the
last call did not result in an error the method returns C<undef>.

=cut

sub lock_errno {
    return shift->{ errno };
}


###########################################################

=pod

=item C<error()>

Returns a short description of the error that happened during the
latest call of C<lock()> with the object. Please take the messages
with a grain of salt, they represent what SUSv3 (IEEE 1003.1-2001)
and the Linux, TRUE64, OpenBSD3 and Solaris8 man pages tell what
the error numbers mean, there could be differences (and additional
error numbers) on other systems. If there was no error the method
returns C<undef>.

=cut

sub error {
    return shift->{ error };
}


###########################################################

=pod

=item C<system_error()>

While the previous method, C<error()>, tries to return a string with
some relevance to the locking operation (i.e. "File or segment already
locked by other process(es)" instead of "Permission denied") this
method returns the "normal" system error message associated with
errno. The method returns C<undef> if there was no error.

=back

=cut

sub system_error {
    local $!;
    my $flock_struct = shift;
    return $flock_struct->{ errno } ? $! = $flock_struct->{ errno } : undef;
}


=pod

=head2 EXPORT

F_GETLK F_SETLK F_SETLKW
F_RDLCK F_WRLCK F_UNLCK
SEEK_SET SEEK_CUR SEEK_END

=head1 CREDITS

Thanks to Mark Jason Dominus (MJD) and Benjamin Goldberg (GOLDBB) for
helpful discussions, code examples and encouragement. Glenn Herteg
pointed out several problems and also helped improve the documentation.
Julian Moreno Patino also helped correcting the documentation and
pointed out problems arising on GNU Hurd (which seems to have only
very rudimentary support for locking with fcntl()).

=head1 AUTHOR

Jens Thoms Toerring <jt@toerring.de>

=head1 SEE ALSO

L<perl(1)>, L<fcntl(2)>, L<lseek(2)>.

=cut


1;

# Local variables:
# tab-width: 4
# indent-tabs-mode: nil
# End:
