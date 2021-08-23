
C.........................................................................
C Version "@(#)$Header: /env/proj/archive/cvs/ioapi_tools/./ioapi_tools/src/gregdate.f,v 1.6 2001/01/03 19:57:55 coats Exp $"
C EDSS/Models-3 M3TOOLS.  Copyright (C) 1992-2001 MCNC
C Distributed under the GNU GENERAL PUBLIC LICENSE version 2
C See file "GPL.txt" for conditions of use.
C.........................................................................

        PROGRAM GREGDATE

C***********************************************************************
C  program body starts at line 73
C
C  DESCRIPTION:  
C	interactively enter julian date YYYYDD;
C	get month, day, year back.
C
C  PRECONDITIONS REQUIRED:
C       none
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C	MMDDYY, GETNUM, GETMENU, STR2INT
C
C  REVISION  HISTORY:
C	Prototype  8/95 by CJC
C       Enhanced   6/98 to support YESTERDAY, TODAY, TOMORROW.
C       Version  11/2001 by CJC for I/O API Version 2.1
C***********************************************************************

      IMPLICIT NONE

C...........   EXTERNAL FUNCTIONS and their descriptions:

        INTEGER		IARGC
        INTEGER		GETNUM
        LOGICAL		ISDSTIME
        INTEGER		STR2INT
        CHARACTER*14    MMDDYY
        INTEGER		WKDAY
        
        EXTERNAL	ISDSTIME, GETNUM, MMDDYY, STR2INT, WKDAY
        
C...........   PARAMETERS and their descriptions:

        CHARACTER*80    PROGVER
        DATA PROGVER /
     &  '$Id$'
     &  /


C...........   LOCAL VARIABLES and their descriptions:
        
        INTEGER		DATE, DAY, JTIME
        INTEGER         ARGCNT  !  number of command-line args, from IARGC()
        CHARACTER*80    SCRBUF

        CHARACTER*10    DAYS( 7 )
        DATA            DAYS
     &  /
     &  'Monday', 'Tuesday', 'Wednesday', 
     &  'Thursday', 'Friday', 'Saturday', 'Sunday'
     &  /

        INTEGER         DLEN( 7 )	! string lengths
        DATA            DLEN
     &  /
     &  6, 7, 9, 
     &  8, 6, 8, 6
     &  /
        INTEGER MNTBUF, MDAY
        CHARACTER*7  YEAR

C***********************************************************************
C   begin body of program GREGDATE

        ARGCNT = IARGC()
        IF ( ARGCNT .EQ. 1 ) THEN
        
            CALL GETARG( ARGCNT, SCRBUF )
            CALL UPCASE( SCRBUF )
            IF ( SCRBUF .EQ. 'TODAY' ) THEN
                CALL GETDTTIME( DATE, JTIME )
            ELSE IF ( SCRBUF .EQ. 'YESTERDAY' ) THEN
                CALL GETDTTIME( DATE, JTIME )
                CALL NEXTIME( DATE, JTIME, -240000 )
            ELSE IF ( SCRBUF .EQ. 'TOMORROW' ) THEN
                CALL GETDTTIME( DATE, JTIME )
                CALL NEXTIME( DATE, JTIME, 240000 )
            ELSE 
                DATE = STR2INT( SCRBUF )
            END IF
        
        END IF
            
        IF ( ARGCNT .NE.       1  .OR.
     &       DATE  .LT. 1000000  .OR.  
     &       DATE  .GT. 9999999 ) THEN
            
            WRITE( *,92000 ) ' ', ' ',
     & 'Program GREGDATE takes julian date (in form YYYYDDD) and',
     & 'returns the date in form "Wkday, Month DD, YYYY".',
     & ' ',
     & '    Usage:  "gregdate [<JDATE>]" ',
     & '    (alt    "gregdate [ YESTERDAY | TODAY | TOMORROW]") ',
     & ' ',
     & '(if the JDATE command-line argument is missing, prompts the ',
     & 'user for JDATE)',
     & ' ',
     &'See URL  http://www.emc.mcnc.org/products/ioapi/AA.html#tools',
     &' ',
     &'Program copyright (C) 2001 MCNC and released under Version 2',
     &'of the GNU General Public License.  See enclosed GPL.txt, or',
     &'URL  http://www.gnu.org/copyleft/gpl.html',
     &'Comments and questions are welcome and can be sent to',
     &' ',
     &'    envpro@emc.mcnc.org',
     &' ',
     &'    MCNC -- Environmental Modeling Center',
     &'    3021 Cornwallis Rd    P. O. Box 12889',
     &'    Research Triangle Park, NC 27709-2889',
     &' ',
     &'Program version: ' // PROGVER, 
     &' ',
     &'Program release tag: $Name$', 
     &' '
            CALL GETDTTIME( DAY, JTIME )
            DATE = GETNUM( 1000000, 9999999, DAY, 
     &                      'Enter Julian date YYYYDDD' )
        
        END IF	!  if argcnt=1, or not

        DAY = WKDAY( DATE )
        WRITE(YEAR,'I7') DATE

        CALL DAYMON ( DATE, MNTBUF, MDAY )
        WRITE(*,93000) MNTBUF, MDAY, YEAR
!       IF ( ISDSTIME( DATE ) ) THEN
!           WRITE( *,92010 ) 
!    &          DAYS( DAY )( 1:DLEN( DAY ) ), 
!    &          MMDDYY( DATE ),
!    &          'Daylight Savings Time in effect.'
!       ELSE
!           WRITE( *,92010 ) 
!    &          DAYS( DAY )( 1:DLEN( DAY ) ), 
!    &          MMDDYY( DATE ),
!    &          'Standard Time in effect.'
!       END IF
!       WRITE( *,92010 ) 

      CALL EXIT( 0 )

C******************  FORMAT  STATEMENTS   ******************************

C...........   Informational (LOG) message formats... 92xxx

92000	FORMAT( 5X, A )

92010	FORMAT( /5X, A, ', ', A, /5X, A, / )
93000   FORMAT( I2.2, 1X, I2.2 , 1X , A4 )

        END

