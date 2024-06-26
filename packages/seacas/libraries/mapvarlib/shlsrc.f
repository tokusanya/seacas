C Copyright(C) 1999-2020 National Technology & Engineering Solutions
C of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C NTESS, the U.S. Government retains certain rights in this software.
C
C See packages/seacas/LICENSE for details

      SUBROUTINE SHLSRC(
     *  NDIM,     NPTS,     NPSRF,    NFSRF,    NISR,
     *  NRSR,     NRSS,     XYZSRF,   XYZPTS,   LINKSRF,
     *  ISRCHR,   RSRCHR,   NN,      IFSRF,     TOLSRCH,
     *  IERR    )

C-----------------------------------------------------------------------

C DESCRIPTION:

C THIS SUBROUTINE CALCULATES THE CLOSEST POINT PROBLEM
C BETWEEN 'KOUNTS' PAIRS OF POINTS AND SURFACES.

C-----------------------------------------------------------------------

C FORMAL PARAMETERS

C MEMORY      : P=PERMANENT, S=SCRATCH
C NAME        : IMPLICIT A-H,O-Z REAL, I-N INTEGER
C TYPE        : INPUT_STATUS/OUTPUT_STATUS (I=INPUT,O=OUTPUT,P=PASSED,
C               U=UNMODIFIED,-=UNDEFINED)
C DESCRIPTION : DESCRIPTION OF VARIABLE

C-----------------------------------------------------------------------

C CALLING ARGUMENTS

C MEMORY NAME     TYPE   DESCRIPTION
C ---    ----     ---    -----------
C  P     NDIM     I/U    DIMENSION OF PROBLEM=3
C  P     NPTS     I/U    NUMBER OF POINTS TO BE SEARCHED
C  P     NPSRF    I/U    NUMBER OF POINTS THAT DEFINE THE SURFACE
C  P     NFSRF    I/U    NUMBER OF SURFACES
C  P     NISR     I/U    NUMBER OF INTEGER SEARCH RESULTS (>=1)
C  P     NRSR     I/U    NUMBER OF REAL SEARCH RESULTS (>=4)
C  P     NRSS     I/U    NUMBER OF REAL SEARCH SCRATCH MEMORY (=10)
C  P     XYZSRF   I/U    XYZ COORDS OF POINTS DEFINING SURFACE
C  P     XYZPTS   I/U    XYZ COORDS OF POINTS TO BE SEARCHED
C  P     LINKSRF  I/U    CONNECTIVITY OF SURFACES OF SIZE (4*NFSRF),
C                        NUMBERS REFER TO LOCATIONS IN XYZSRF ARRAY
C  P     ISRCHR   I/O    INTEGER SEARCH RESULTS
C  P     RSRCHR   I/O    REAL SEARCH RESULTS
C  P     NN       I/U    POINT PAIRED WITH SURFACE IFSRF
C  P     IFSRF   I/U     SURFACE PAIRED WITH POINT NN
C  S     CTRCL    -/-    TRACKING ARRAY FOR KOUNTS POINT-SURFACE PAIRS
C  P     TOLSRCH  I/U    PROXIMITY TOLERANCE FOR POINT-TO-SURFACE SEARCH

C-----------------------------------------------------------------------

C INPUT/OUTPUT ARRAYS
      DIMENSION
     *  XYZPTS(NPTS,NDIM)   ,XYZSRF(NPSRF,NDIM)  ,LINKSRF(4,NFSRF)    ,
     *  ISRCHR(NISR,NPTS)   ,RSRCHR(NRSR,NPTS)
C SCRATCH ARRAYS
      DIMENSION CTRCL(10)

C ... Eliminate uninitialized variable warning...
      do i=1, 10
        ctrcl(i) = 0.0
      end do

      IF( NISR .LT. 1 .OR. NRSR .LT. 4 .OR. NRSS .LT. 10 )THEN
        IERR = 1
        RETURN
      ENDIF
      ZERO = 0
      ONE = 1

C COMPUTE SURFACE NORMALS AND STORE
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
      UX = -XYZSRF(N1,1) +XYZSRF(N2,1) +XYZSRF(N3,1) -XYZSRF(N4,1)
      UY = -XYZSRF(N1,2) +XYZSRF(N2,2) +XYZSRF(N3,2) -XYZSRF(N4,2)
      UZ = -XYZSRF(N1,3) +XYZSRF(N2,3) +XYZSRF(N3,3) -XYZSRF(N4,3)
      VX = -XYZSRF(N1,1) -XYZSRF(N2,1) +XYZSRF(N3,1) +XYZSRF(N4,1)
      VY = -XYZSRF(N1,2) -XYZSRF(N2,2) +XYZSRF(N3,2) +XYZSRF(N4,2)
      VZ = -XYZSRF(N1,3) -XYZSRF(N2,3) +XYZSRF(N3,3) +XYZSRF(N4,3)
      PMX = UY * VZ - UZ * VY
      PMY = UZ * VX - UX * VZ
      PMZ = UX * VY - UY * VX
      PMAG = SQRT( PMX*PMX + PMY*PMY + PMZ*PMZ )
      CTRCL(8)  = PMX / PMAG
      CTRCL(9)  = PMY / PMAG
      CTRCL(10) = PMZ / PMAG

C SURFACE NORMAL
      A4I = CTRCL(8)
      A4J = CTRCL(9)
      A4K = CTRCL(10)
C POINT LOCATION
      XSD = XYZPTS(NN,1)
      YSD = XYZPTS(NN,2)
      ZSD = XYZPTS(NN,3)
C NODE NUMBERS IN CURRENT SURFACE NODE LIST
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
C COMPUTE NORMAL DISTANCE FROM THE SURFACE TO THE POINT
C NOTE THAT A NEGATIVE DISTANCE IMPLIES THE POINT IS INSIDE THE FACE
      VX1S = XSD - XYZSRF(N1,1)
      VY1S = YSD - XYZSRF(N1,2)
      VZ1S = ZSD - XYZSRF(N1,3)
C DOT THE VECTOR FROM POINT 1 ON SURFACE TO THE POINT
C WITH THE OUTWARD UNIT NORMAL
      PROJN = VX1S*A4I + VY1S*A4J + VZ1S*A4K
C FIND CLOSEST POINT
      XC = XSD - PROJN*A4I
      YC = YSD - PROJN*A4J
      ZC = ZSD - PROJN*A4K
C DETERMINE IF THE CLOSEST POINT IS INSIDE THE SURFACE
      VX1 = XYZSRF(N1,1) - XC
      VY1 = XYZSRF(N1,2) - YC
      VZ1 = XYZSRF(N1,3) - ZC
      VX2 = XYZSRF(N2,1) - XC
      VY2 = XYZSRF(N2,2) - YC
      VZ2 = XYZSRF(N2,3) - ZC
      VX3 = XYZSRF(N3,1) - XC
      VY3 = XYZSRF(N3,2) - YC
      VZ3 = XYZSRF(N3,3) - ZC
      VX4 = XYZSRF(N4,1) - XC
      VY4 = XYZSRF(N4,2) - YC
      VZ4 = XYZSRF(N4,3) - ZC
      A1 = ( VY1*VZ2-VY2*VZ1)*A4I +
     *  (-VX1*VZ2+VX2*VZ1)*A4J +
     *  ( VX1*VY2-VX2*VY1)*A4K
      A2 = ( VY2*VZ3-VY3*VZ2)*A4I +
     *  (-VX2*VZ3+VX3*VZ2)*A4J +
     *  ( VX2*VY3-VX3*VY2)*A4K
      A3 = ( VY3*VZ4-VY4*VZ3)*A4I +
     *  (-VX3*VZ4+VX4*VZ3)*A4J +
     *  ( VX3*VY4-VX4*VY3)*A4K
      A4 = ( VY4*VZ1-VY1*VZ4)*A4I +
     *  (-VX4*VZ1+VX1*VZ4)*A4J +
     *  ( VX4*VY1-VX1*VY4)*A4K
C AREA COORDS
      XCOORD = (2*A4/(A4+A2) - 1)
      ECOORD = (2*A1/(A1+A3) - 1)
      CTRCL(1) = 0
      IF( ABS(PROJN)  .LE. TOLSRCH )THEN
        CTRCL(1) = IFSRF
        CTRCL(2) = XCOORD
        CTRCL(3) = ECOORD
        CTRCL(4) = PROJN
        CTRCL(5) = A4I
        CTRCL(6) = A4J
        CTRCL(7) = A4K
        IF( ABS(XCOORD) .GT. 1 .OR. ABS(ECOORD) .GT. 1 )
     *    CTRCL(1) = -CTRCL(1)
      ENDIF

C SURFACE NORMAL
      A4I = CTRCL(8)
      A4J = CTRCL(9)
      A4K = CTRCL(10)
C LOCAL COORDS
      XCOORD = CTRCL(2)
      ECOORD = CTRCL(3)
C NODE NUMBERS IN CURRENT SURFACE NODE LIST
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
      IF( XCOORD .GT. 1 ) THEN
        VXS = XYZSRF(N3,1) - XYZSRF(N2,1)
        VYS = XYZSRF(N3,2) - XYZSRF(N2,2)
        VZS = XYZSRF(N3,3) - XYZSRF(N2,3)
        VXP = XYZPTS(NN,1) - XYZSRF(N2,1)
        VYP = XYZPTS(NN,2) - XYZSRF(N2,2)
        VZP = XYZPTS(NN,3) - XYZSRF(N2,3)
C  PROJECTION OF VECTOR FROM SURFACE NODE TO POINT ONTO THE
C  VECTOR FROM SURFACE NODE 1 TO NODE 2, AND THE LOCAL COORD, S
        PROJPS = VXP*VXS + VYP*VYS + VZP*VZS
        VMAGPS = ABS(VXS*VXS+VYS*VYS+VZS*VZS)
C  LOCAL COORD. (S) ALONG 1-2
        SPS = PROJPS/VMAGPS
        SPS = MAX(ZERO,SPS)
        SPS = MIN(ONE,SPS)
C  NEAREST POINT ON LINE 1-2
        XC12 = XYZSRF(N2,1) + SPS*VXS
        YC12 = XYZSRF(N2,2) + SPS*VYS
        ZC12 = XYZSRF(N2,3) + SPS*VZS
C  VECTOR FROM NEAREST POINT TO SLAVE NODE
        VCS12X = XYZPTS(NN,1)-XC12
        VCS12Y = XYZPTS(NN,2)-YC12
        VCS12Z = XYZPTS(NN,3)-ZC12
C  DISTANCE FROM NEAREST POINT TO SLAVE NODE
        DISPS = SQRT(VCS12X*VCS12X+VCS12Y*VCS12Y+VCS12Z*VCS12Z)
C  DOT DISTANCE WITH SURFACE NORMAL TO DETERMINE POS. OR NEG. DIST.
        SDIS = VCS12X*A4I+VCS12Y*A4J+VCS12Z*A4K
        PROJN = SIGN(DISPS,SDIS)
C  RECOMPUTE LOCAL COORDS
        XCOORD = 1
        ECOORD = 2*SPS - 1
        IF( DISPS .LT. 1.E-6 )THEN
          VCS12X = A4I
          VCS12Y = A4J
          VCS12Z = A4K
          DISPS = 1.
        ENDIF
        CTRCL(1) = -IFSRF
        CTRCL(2) = XCOORD
        CTRCL(3) = ECOORD
        CTRCL(4) = PROJN
        CTRCL(5) = VCS12X/DISPS
        CTRCL(6) = VCS12Y/DISPS
        CTRCL(7) = VCS12Z/DISPS
      ENDIF

C SURFACE NORMAL
      A4I = CTRCL(8)
      A4J = CTRCL(9)
      A4K = CTRCL(10)
C LOCAL COORDS
      XCOORD = CTRCL(2)
      ECOORD = CTRCL(3)
C NODE NUMBERS IN CURRENT SURFACE NODE LIST
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
      IF( XCOORD .LT. -1 )THEN
        VXS = XYZSRF(N4,1) - XYZSRF(N1,1)
        VYS = XYZSRF(N4,2) - XYZSRF(N1,2)
        VZS = XYZSRF(N4,3) - XYZSRF(N1,3)
        VXP = XYZPTS(NN,1) - XYZSRF(N1,1)
        VYP = XYZPTS(NN,2) - XYZSRF(N1,2)
        VZP = XYZPTS(NN,3) - XYZSRF(N1,3)
C  PROJECTION OF VECTOR FROM SURFACE NODE TO POINT ONTO THE
C  VECTOR FROM SURFACE NODE 1 TO NODE 2, AND THE LOCAL COORD, S
        PROJPS = VXP*VXS + VYP*VYS + VZP*VZS
        VMAGPS = ABS(VXS*VXS+VYS*VYS+VZS*VZS)
C  LOCAL COORD. (S) ALONG 1-2
        SPS = PROJPS/VMAGPS
        SPS = MAX(ZERO,SPS)
        SPS = MIN(ONE,SPS)
C  NEAREST POINT ON LINE 1-2
        XC12 = XYZSRF(N1,1) + SPS*VXS
        YC12 = XYZSRF(N1,2) + SPS*VYS
        ZC12 = XYZSRF(N1,3) + SPS*VZS
C  VECTOR FROM NEAREST POINT TO SLAVE NODE
        VCS12X = XYZPTS(NN,1)-XC12
        VCS12Y = XYZPTS(NN,2)-YC12
        VCS12Z = XYZPTS(NN,3)-ZC12
C  DISTANCE FROM NEAREST POINT TO SLAVE NODE
        DISPS = SQRT(VCS12X*VCS12X+VCS12Y*VCS12Y+VCS12Z*VCS12Z)
C  DOT DISTANCE WITH SURFACE NORMAL TO DETERMINE POS. OR NEG. DIST.
        SDIS = VCS12X*A4I+VCS12Y*A4J+VCS12Z*A4K
        PROJN = SIGN(DISPS,SDIS)
C  RECOMPUTE LOCAL COORDS
        XCOORD = -1
        ECOORD = 2*SPS - 1
        IF( DISPS .LT. 1.E-6 )THEN
          VCS12X = A4I
          VCS12Y = A4J
          VCS12Z = A4K
          DISPS = 1.
        ENDIF
        CTRCL(1) = -IFSRF
        CTRCL(2) = XCOORD
        CTRCL(3) = ECOORD
        CTRCL(4) = PROJN
        CTRCL(5) = VCS12X/DISPS
        CTRCL(6) = VCS12Y/DISPS
        CTRCL(7) = VCS12Z/DISPS
      ENDIF

C SURFACE NORMAL
      A4I = CTRCL(8)
      A4J = CTRCL(9)
      A4K = CTRCL(10)
C LOCAL COORDS
      XCOORD = CTRCL(2)
      ECOORD = CTRCL(3)
C NODE NUMBERS IN CURRENT SURFACE NODE LIST
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
      IF( ECOORD .GT. 1 )THEN
        VXS = XYZSRF(N3,1) - XYZSRF(N4,1)
        VYS = XYZSRF(N3,2) - XYZSRF(N4,2)
        VZS = XYZSRF(N3,3) - XYZSRF(N4,3)
        VXP = XYZPTS(NN,1) - XYZSRF(N4,1)
        VYP = XYZPTS(NN,2) - XYZSRF(N4,2)
        VZP = XYZPTS(NN,3) - XYZSRF(N4,3)
C  PROJECTION OF VECTOR FROM SURFACE NODE TO POINT ONTO THE
C  VECTOR FROM SURFACE NODE 1 TO NODE 2, AND THE LOCAL COORD, S
        PROJPS = VXP*VXS + VYP*VYS + VZP*VZS
        VMAGPS = ABS(VXS*VXS+VYS*VYS+VZS*VZS)
C  LOCAL COORD. (S) ALONG 1-2
        SPS = PROJPS/VMAGPS
        SPS = MAX(ZERO,SPS)
        SPS = MIN(ONE,SPS)
C  NEAREST POINT ON LINE 1-2
        XC12 = XYZSRF(N4,1) + SPS*VXS
        YC12 = XYZSRF(N4,2) + SPS*VYS
        ZC12 = XYZSRF(N4,3) + SPS*VZS
C  VECTOR FROM NEAREST POINT TO SLAVE NODE
        VCS12X = XYZPTS(NN,1)-XC12
        VCS12Y = XYZPTS(NN,2)-YC12
        VCS12Z = XYZPTS(NN,3)-ZC12
C  DISTANCE FROM NEAREST POINT TO SLAVE NODE
        DISPS = SQRT(VCS12X*VCS12X+VCS12Y*VCS12Y+VCS12Z*VCS12Z)
C  DOT DISTANCE WITH SURFACE NORMAL TO DETERMINE POS. OR NEG. DIST.
        SDIS = VCS12X*A4I+VCS12Y*A4J+VCS12Z*A4K
        PROJN = SIGN(DISPS,SDIS)
C  RECOMPUTE LOCAL COORDS
        XCOORD = 2*SPS - 1
        ECOORD = 1
        IF( DISPS .LT. 1.E-6 )THEN
          VCS12X = A4I
          VCS12Y = A4J
          VCS12Z = A4K
          DISPS = 1.
        ENDIF
        CTRCL(1) = -IFSRF
        CTRCL(2) = XCOORD
        CTRCL(3) = ECOORD
        CTRCL(4) = PROJN
        CTRCL(5) = VCS12X/DISPS
        CTRCL(6) = VCS12Y/DISPS
        CTRCL(7) = VCS12Z/DISPS
      ENDIF

C SURFACE NORMAL
      A4I = CTRCL(8)
      A4J = CTRCL(9)
      A4K = CTRCL(10)
C LOCAL COORDS
      XCOORD = CTRCL(2)
      ECOORD = CTRCL(3)
C NODE NUMBERS IN CURRENT SURFACE NODE LIST
      N1 = LINKSRF(1,IFSRF)
      N2 = LINKSRF(2,IFSRF)
      N3 = LINKSRF(3,IFSRF)
      N4 = LINKSRF(4,IFSRF)
      IF( ECOORD .LT. -1 )THEN
        VXS = XYZSRF(N2,1) - XYZSRF(N1,1)
        VYS = XYZSRF(N2,2) - XYZSRF(N1,2)
        VZS = XYZSRF(N2,3) - XYZSRF(N1,3)
        VXP = XYZPTS(NN,1) - XYZSRF(N1,1)
        VYP = XYZPTS(NN,2) - XYZSRF(N1,2)
        VZP = XYZPTS(NN,3) - XYZSRF(N1,3)
C  PROJECTION OF VECTOR FROM SURFACE NODE TO POINT ONTO THE
C  VECTOR FROM SURFACE NODE 1 TO NODE 2, AND THE LOCAL COORD, S
        PROJPS = VXP*VXS + VYP*VYS + VZP*VZS
        VMAGPS = ABS(VXS*VXS+VYS*VYS+VZS*VZS)
C  LOCAL COORD. (S) ALONG 1-2
        SPS = PROJPS/VMAGPS
        SPS = MAX(ZERO,SPS)
        SPS = MIN(ONE,SPS)
C  NEAREST POINT ON LINE 1-2
        XC12 = XYZSRF(N1,1) + SPS*VXS
        YC12 = XYZSRF(N1,2) + SPS*VYS
        ZC12 = XYZSRF(N1,3) + SPS*VZS
C  VECTOR FROM NEAREST POINT TO SLAVE NODE
        VCS12X = XYZPTS(NN,1)-XC12
        VCS12Y = XYZPTS(NN,2)-YC12
        VCS12Z = XYZPTS(NN,3)-ZC12
C  DISTANCE FROM NEAREST POINT TO SLAVE NODE
        DISPS = SQRT(VCS12X*VCS12X+VCS12Y*VCS12Y+VCS12Z*VCS12Z)
C  DOT DISTANCE WITH SURFACE NORMAL TO DETERMINE POS. OR NEG. DIST.
        SDIS = VCS12X*A4I+VCS12Y*A4J+VCS12Z*A4K
        PROJN = SIGN(DISPS,SDIS)
C  RECOMPUTE LOCAL COORDS
        XCOORD = 2*SPS - 1
        ECOORD = -1
        IF( DISPS .LT. 1.E-6 )THEN
          VCS12X = A4I
          VCS12Y = A4J
          VCS12Z = A4K
          DISPS = 1.
        ENDIF
        CTRCL(1) = -IFSRF
        CTRCL(2) = XCOORD
        CTRCL(3) = ECOORD
        CTRCL(4) = PROJN
        CTRCL(5) = VCS12X/DISPS
        CTRCL(6) = VCS12Y/DISPS
        CTRCL(7) = VCS12Z/DISPS
      ENDIF

C SELECT THE CLOSEST SURFACE

      IF( NINT(CTRCL(1)) .NE. 0 )THEN

C STORE CURRENT SEARCH RESULTS
        IF( ISRCHR(1,NN) .EQ. 0 )THEN
C STORE INTEGER SEARCH RESULTS
          ISRCHR(1,NN) = NINT(ABS(CTRCL(1)))
          ITYPE = 1
          IF( NINT(CTRCL(1)) .LT. 0 ) ITYPE = 2
          IF( NISR .GE. 2 ) ISRCHR(2,NN) = ITYPE
C STORE INTEGER SEARCH RESULTS
          RSRCHR(1,NN) = CTRCL(5)
          RSRCHR(2,NN) = CTRCL(6)
          RSRCHR(3,NN) = CTRCL(7)
          RSRCHR(4,NN) = CTRCL(4)
          IF( NRSR .GE. 6 ) THEN
            RSRCHR(5,NN) = CTRCL(2)
            RSRCHR(6,NN) = CTRCL(3)
          ENDIF
        ELSE
C KEEP CURRENT SEARCH RESULTS ONLY IF CLOSER
          IF( ABS(CTRCL(4)) .LT. ABS(RSRCHR(4,NN)) )THEN
C STORE INTEGER SEARCH RESULTS
            ISRCHR(1,NN) = NINT(ABS(CTRCL(1)))
            ITYPE = 1
            IF( CTRCL(1) .LT. 0 ) ITYPE = 2
            IF( NISR .GE. 2 ) ISRCHR(2,NN) = ITYPE
C STORE INTEGER SEARCH RESULTS
            RSRCHR(1,NN) = CTRCL(5)
            RSRCHR(2,NN) = CTRCL(6)
            RSRCHR(3,NN) = CTRCL(7)
            RSRCHR(4,NN) = CTRCL(4)
            IF( NRSR .GE. 6 ) THEN
              RSRCHR(5,NN) = CTRCL(2)
              RSRCHR(6,NN) = CTRCL(3)
            ENDIF
          ENDIF
        ENDIF
      ENDIF

      RETURN
      END
