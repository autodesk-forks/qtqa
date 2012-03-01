#############################################################################
##
## Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies).
## Contact: http://www.qt-project.org/
##
## This file is part of the Quality Assurance module of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## GNU Lesser General Public License Usage
## This file may be used under the terms of the GNU Lesser General Public
## License version 2.1 as published by the Free Software Foundation and
## appearing in the file LICENSE.LGPL included in the packaging of this
## file. Please review the following information to ensure the GNU Lesser
## General Public License version 2.1 requirements will be met:
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## In addition, as a special exception, Nokia gives you certain additional
## rights. These rights are described in the Nokia Qt LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU General
## Public License version 3.0 as published by the Free Software Foundation
## and appearing in the file LICENSE.GPL included in the packaging of this
## file. Please review the following information to ensure the GNU General
## Public License version 3.0 requirements will be met:
## http://www.gnu.org/copyleft/gpl.html.
##
## Other Usage
## Alternatively, this file may be used in accordance with the terms and
## conditions contained in a signed written agreement between you and Nokia.
##
##
##
##
##
##
## $QT_END_LICENSE$
##
#############################################################################

package QtQA::PerlChecks;
use strict;
use warnings;

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( all_files_in_git all_perl_files_in_git );

use File::chdir;
use File::Spec::Functions;
use List::MoreUtils qw( apply );
use Perl::Critic::Utils qw( all_perl_files );
use Test::More;

# Helper for tests in this directory to find perl files for testing.

# Returns a list of all files known to git under the given $path (or '.' if unset)
# It is considered a failure if there are no files known to git.
sub all_files_in_git
{
    my ($path) = @_;

    if (!$path) {
        $path = '.';
    }

    # Do everything from $path, so we get filenames relative to that
    local $CWD = $path;

    # Find all the files known to git
    my @out =
        apply { canonpath } # make paths canonical ...
        apply { chomp }     # strip all newlines ...
            qx( git ls-files );

    # Get files in a reliable order
    @out = sort @out;

    is( $?, 0, 'git ls-files ran ok' );
    ok( @out,  'git ls-files found some files' );

    return @out;
}

# Returns a list of all perl files known to git under the given $path.
# See Perl::Critic::Utils all_perl_files for documentation on what
# "perl files" means.
# May return an empty list if there are no perl files.
sub all_perl_files_in_git
{
    my ($path) = @_;

    if (!$path) {
        $path = '.';
    }

    # Do everything from $path, so we get filenames relative to that
    local $CWD = $path;

    # Find all the git files ...
    my %all_git_files = map { $_ => 1 } all_files_in_git( '.' );

    # Then return only those perl files which are also in git
    my @out = grep { $all_git_files{ $_ } } all_perl_files( '.' );

    # Get files in a reliable order
    @out = sort @out;

    return @out;
}

1;

