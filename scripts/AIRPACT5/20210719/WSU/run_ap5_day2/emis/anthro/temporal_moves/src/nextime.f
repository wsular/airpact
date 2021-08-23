
        PROGRAM NETXIME

C***********************************************************************
C
C  DESCRIPTION:  
C	interactively month, day, year;
C	get julian date YYYYDD back.
C
C  PRECONDITIONS REQUIRED:
C       none
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C	JULIAN, GETNUM
C
C  REVISION  HISTORY:
C***********************************************************************

      IMPLICIT NONE

C...........   EXTERNAL FUNCTIONS and their descriptions:

        INTEGER		IARGC
        INTEGER		GETNUM
        INTEGER		STR2INT
        
        EXTERNAL	GETNUM, STR2INT
     
C...........   PARAMETERS and their descriptions:

        CHARACTER*16 :: PROGNAME = 'NEXTIME'

C...........   LOCAL VARIABLES and their descriptions:
        
        INTEGER		JDATE, JTIME, DTIME
        CHARACTER*10    ARGBUF  ! argument character buffer
        INTEGER         ARGCNT  !  number of command-line args, from IARGC()
        LOGICAL         PFLAG

C***********************************************************************
C   begin body of program

        ARGCNT = IARGC()
        CALL GETDTTIME( JDATE, JTIME )  ! current system time date

        IF ( ARGCNT .EQ. 1 ) THEN

        ELSE IF ( ARGCNT .EQ. 3 ) THEN
        
            CALL GETARG( 1, ARGBUF )
            JDATE = STR2INT( TRIM( ARGBUF ) )
            CALL GETARG( 2, ARGBUF )
            JTIME = STR2INT( TRIM( ARGBUF ) )
            CALL GETARG( 3, ARGBUF )
            DTIME = STR2INT( TRIM( ARGBUF ) )

! error check for input
!           PFLAG = ( MON    .GT.   12  .OR.
!    &                MON    .LT.    1  .OR.
!    &                DAY    .GT.   31  .OR.
!    &                DAY    .LT.    1  .OR.
!    &                YR     .LT. 1000  .OR.
!    &                YR     .GT. 9999 ) !  malformed input:  prompt user

        ELSE

            PFLAG = .TRUE.      !  prompt user

        END IF
            
        IF ( PFLAG ) THEN
            
            WRITE( *,92000 ) ' ', ' ',
     & 'Program nextime takes in DATE <YYYYDDD>, TIME <HHMMSS> ',
     & 'and DTIME <HHMMSS> and output corresponding DATE <YYYYDDD>',
     & 'and TIME <HHMMSS> using the nextime subroutin in netCDF-IOAPI',
     & 'library',
     & ' ',
     & '    Usage:  "nextime [<DATE TIME DTIME>]" ', ' ',
     & '(if the command-line arguments are missing, prompts the ',
     & 'user for them)',
     & ' '

            JDATE = GETNUM( 1900001, 3000001, JDATE, 'Enter DATE <YYYYDDD>' )

            JTIME = GETNUM( 0, 9995959, 000000, 'Enter TIME <HHMMSS>' )

            DTIME = GETNUM( -9995959, 9995959, 10000, 'Enter DTIME <HHMMSS>' )

        END IF	!  if argcnt=3, or not

        CALL NEXTIME ( JDATE, JTIME, DTIME )
        WRITE(*,93000) JDATE, JTIME
        
      CALL EXIT( JDATE )

C******************  FORMAT  STATEMENTS   ******************************

C...........   Informational (LOG) message formats... 92xxx

92000	FORMAT( 5X, A )

92010	FORMAT( /, 5X, A, ', ', I7.7, /5X, A, / )
93000   FORMAT( I7.7,1X,I6.6 )

        END

