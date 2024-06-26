      implicit real*8 (A-H,O-Z)
      complex*16 cim, ccim, sphrm, dcmplx	
      common/b1/cim,ccim,c(16,16),fac(13),dac(13),ngln(10),
     1alamda,twopi,fpl30m,sws,vol,soo,swsl,fpilam,rmax,gmax,icnvrg,
     2numvr,numvg,nq,nro,nl2,nl2p,klmo,nl,nlm,lmq,nowrt,idim
      common/b2/srl(2916),sil(2916)
      COMMON/MSH/DKX,DKY,DKZ,DHX,BOA,COA,KX(2500),KY(2500),KZ(2500),
     1W(2500)
      common/vec/bsx(3),bsy(3),bsz(3),bkx(3),bky(3),bkz(3),qx(6),qy(6),
     1qz(6),asx(500),asy(500),asz(500),akx(500),aky(300),akz(400),
     2dr(500),dg(300),
     3usx(500),usy(500),usz(500),ukx(300),uky(300),ukz(300)	
      character*4 TLAT(8) /'  SC',' FCC',' BCC',' HCP','  ST',' BCT'
     1,'AL-U','trig'/
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
ccccccccccccccccccccccccccccccwork around here ccccccccccccccccccccccc
c      character txt(15)
c      CHARACTER*4 POINT      
c      INTEGER IDUM1            
c      real*8 DUM1
c      DATA POINT/'    '/, IDUM1/0/, DUM1/0.D0/
CCCCCCCCCCCCCCCCCCCCC WORKING AROUND ORIGINAL ISSUE CODE COMMENTED BELOW  CCC    
c next two lines do not work       
      ,point
      data point/'    '/,idum1/0/,dum1/0.d0/
    1 format(15a4)
    2 format(3e15.7)
    3 format(2i5,5x,10i1,e15.7)   
    4 format(1h ,//,11x,'basisvectors',//)
    5 format(1h1,10x,15a4,/)
    6 format(1h,10x,'rmax',g10.5,' gmax',f10.5,/
     1,10x,' nl',i4,' nq',i4,' nlm',i4,' lmq',i4,/,10x,' lamda',f10.5,
     2' ngln ',10i1,/,10x,' novcgn',i4,' nowrt'i4,' icnvrg',i4,/)
    7 format(4i5)
    8 format(3f10.6,a4)
    9 FORMAT(1H ,//,11X,'POINT NUMBER',I5,5X,'PKX,PKY,PKZ',3F10.4,
     15X, 'W',F10.4,5X,A4)
   10 FORMAT(1H ,11X,'VOL',F15.7,' SWS',F15.7,' SOO',F15.7)
   11 FORMAT(1H 11X,'(',F10.5,',',F10.5,',',F10.5,')')
   12 FORMAT(1H ,//,11X,'PRIMITIVE VECTORS IN UNIT CELL OF ',A4,//,11X,
     1'BOA',F15.10,' COA',F15.10,//)
   13 FORMAT(2F10.5,3I5)
   14 FORMAT(1H ,/,11X,'**MATRICES GENERATED AT AN EARLIER RUN**',//)
   15 FORMAT(I5,2E15.8)
   16 FORMAT(1H ,//,11X,'MODE,NPX,NPY,NPZ,NPT',5I5)
      IDIM=54
      CIM=DCMPLX(0.D00,1.D00)
      CCIM=DCMPLX(0.D00,-1.D00)
      PI=4.D00*DATAN(1.D00)
      TWOPI=2.D00*PI
      FOURPI=4.D00*PI
      READ(5,1) TXT
      TXT(15) = ' NEW'
      READ(5,13) RMAX, GMAX, NOVCGN, NOWRT, ICNVRG
      READ(5,3) NL, NQ, NGLN, ALAMDA
      READ(5,15) LAT, BOA, COA
      NLM=NL*NQ
      LMQ=NLM*NQ
      NL2=2*NL-1
C     
C      IF LPP.GT.5 ONLY REAL SPACE SUMMATIONS IN <SMTRX>
C      
      NL2P=MIN0(5,NL2)
      L=NL2-1
      KLMO=L*(L+1)+L+1

      CALL FACTOR(4*(NL-1))
      CALL GAUNT
      CALL LIMAO(NGLN(1),SOO)

      WRITE(6,5) TXT
      WRITE(6,6) RMAX, GMAX, NL, NQ, NLM, LMQ, ALAMDA, NGLN, NOVCGN,
     1NOWRT, ICNVRG
C      READ PRIMITIVE VECTORS BSX, BSY, BSZ OF REAL SPACE
      DO 20 I=1,3
   20 READ(5,2) BSX(I), BSY(I), BSZ(I)
           
      DO 21 I=1,NQ
   21 READ(5,2) QX(I), QY(I), QZ(I)
      WRITE(6,12) TLAT(LAT), BOA, COA
      DO 30 I=1,3
   30 WRITE(6,11) BSX(I), BSY(I), BSZ(I)
      DO 25 I=1,NQ
   25 WRITE(6,11) QX(I), QY(I), QZ(I)
      
C      GENERATE THE NUMVR AND NUMVG SHORTEST VECTORS
c      OF REAL AND RECIPROCAL SPACE
      
      CALL VECGEN(NUMR, NUMG, NOVCGN, LAT)
      SWS = (3.D00*VOL/FOURPI)**(1.D00/3.D00)
      SWSL = SWS*ALAMDA
      FPL30M = FOURPI*ALAMDA**3.D00/VOL
      FPLAM = FOURPI*ALAMDA
      WRITE(6,10) VOL, SWS, SOO
      READ(5,7) MODE, NPX, NPY, NPZ
      IF (MODE.EQ.1) GO TO 28
C     GENERATE MESH IN K-SPACE
      CALL MESH(LAT, NPX, NPY, NPZ, NPT)

      WRITE(6,16) MODE, NPX, NPY, NPZ, NPT
      WRITE(9) TXT, NL, NQ, NLM, LMQ, SWS
      WRITE(19) NPX, NPY, NPZ, LAT, NPT, BOA, COA, DUM1
      
      DO 23 NP=1,NPT
      KKX=KX(NP)
      KKY=KY(NP)
      KKZ=KZ(NP)
      CALL KTRNSF(LAT, KKX, KKY, KKZ, PKX, PKY, PKZ)
      IF (NOWRT.GT.0) WRITE(6,9) NP, PKX, PKY, PKZ, W(NP), POINT
      W=W(NP)
      WRITE(9) NP, PKX, PKY, PKZ, W, POINT, KKX, KKY, KKZ
      PKXP=PKX*PI
      PKYP=PKY*PI
      PKZP=PKZ*PI
      
      CALL SMTRX(PKXP, PKYP, PKZP)
      
      J1=-IDIM
      DO 24 J=J1, LMQ
      J1=J1+IDIM
      I=J1+JDIM
      I2=J1+LMQ
      WRITE(9) (SRL(LIN), LIN=I1, I2)
   24 WRITE(9) (SIL(LIN), LIN=I1, I2)
   23 CONTINUE
c     this errors 
      CLOSE (9,DISP=CRUNCH)

      STOP

   28 WW = 0.D0
      NPOINT = NPX
      WRITE(6, 16) MODE, NPX, NPY, NPZ, NPOINT
      WRITE(9) TXT, NL, NQ, NLM, LMQ, SWS
      KKY = 0
      KKX = 0
      KKZ = 0
      FX = PI
      FY = PI / BOA
      FZ = PI / COA
      FHX = 0.D0
      IF (LAT .NE. 4) GO TO 27
      FX = 2.D0 / 3.D0 * PI
      FY = PI / DSQRT(3.D0)
      FHX = -0.5D0 * FX

            
   27 DO 29 I=1,NPOINT
      READ(5,8) OKX, OKY, OKZ, POINT
      WRITE(6,9) I, OKX, OKY, OKZ, W, POINT
      WRITE(9) OKX, OKY, OKZ, W, POINT, KKX, KKY, KKZ
      PKXP = OKX*FX*FHX*OKY
      PKYP = OKY*FY
      PKZP = OKZ*FZ
   29 CONTINUE
      
c      CALL SMTRX(PKXP, PKYP, PKZP)
      
      J1 = -IDIM
      DO 26 J=J1, LMQ
      J1 = J1 + IDIM
      I = J1 + JDIM
      I2 = J1 + LMQ
      WRITE(9) (SRL(LIN), LIN=I1, I2)
      WRITE(9) (SIL(LIN), LIN=I1, I2)
   26 CONTINUE
c     this errors
      CLOSE(9, DISP=CRUNCH)
      STOP
      END
      BLOCK DATA
C **********************************************************************
C*                                                                     *     
C*    INSERT LM-DATA                                                   *
C*                                                                     *
C **********************************************************************
      COMMON /LDATA/ LL(49), MM(49)
      DATA LL/0,3*1,5*2,7*3,9*4,11*5,13*6/
      DATA MM/0,-1,0,1,-2,-1,0,1,2,-3,-2,-1,0,1,2,3,-4,-3,-2,-1,0,1,2,3,
     14,-5,-4,-3,-2,-1,0,1,2,3,4,5,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6/
      END

      SUBROUTINE VECGEN(NUMR, NUMG, NOVCGN, LAT)
C **********************************************************************
C *                                                                    *
C *                                                                    *
C *                                                                    *
C * GENERATE VECTORS OF DIRECT AND RECIPROCAL SPACE FROM               *
C * BASIC TRANSLATION VECTORS (BSX, BSY, BSZ)                          *
C *                                                                    *
C **********************************************************************
      IMPLICIT REAL*8 (A-H, O-Z)
      COMPLEX*16 CIM, CCIM
      COMMON /B1/CIM, CCIM, CC(16, 16), FAC(13), DAC(13), NGLN(10),
     1ALAMDA,TWOPI,FPL30M,SWS,VOL,SOO, SWSL, FPLAM, RMAX, GMAX, ICNVRG,
     2NUMVR, NUMVG, NQ, NR0,NL2, NL2P, KLM0, NL, NLM, LMQ, NOWRT, IDIM
      COMMON /MSH/DKX,DKY,DKZ,DHX,BOA,COA,KX(2000),KY(2000),KZ(2000),
     1W(2000)
      COMMON/VEC/BSX(3),BSY(3),BSZ(3),BKX(3),BKY(3),BKZ(3),QX(6),QY(6),
     1QZ(6),ASX(500),ASY(500),ASZ(500),AKX(500),AKY(300),AKZ(300),
     2DR(500),DG(300),
     3USX(500),USY(500),USZ(500),UKX(300),UKY(300),UKZ(300)
      DIMENSION CSX(500),CSY(500),CSZ(500),D(500),DD(3),DK(3)
      INTEGER NSR(50),NSG(50)

    1 FORMAT(1H,//, 15X,'SHELL NUMBER',I5,' WITH',I5,' POINTS',//)
    2 FORMAT(1H 10X,I5,4F10.6)
    3 FORMAT(1H ,10X,'(',F10.5,',',F10.5,',',F10.5,')',/)
    4 FORMAT(1H1 ,14X,'RESULT FROM VECGEN FOR REAL SPACE VECTORS',//,
     114X,'NO',5X,'SX',8X,'SY',8X,'SZ',8X,'D',/)
    5 FORMAT(1H ,10X,'RESULT FROM VECGEN FOR RECIPROCAL SPACE VECTORS',
     1 //,'NO',5X,'KX',8X,'KY',8X,'KZ',8X,'D',/)
    6 FORMAT(1H,//,11X,'PRIMITIVE VECTORS OF RECIPROCAL SPACE',/)
    7 FORMAT(1H,//,11X,'R1',F10.4,'RA',F10.4,/,11X,'G1',F10.4,
     1' GA',F10.4,/) 
    8 FORMAT(1H ,'//',11X,'VALUES GENERATED AT PREVIOUS RUN OF VECGEN , (R
     1IMAX,NUMVR,GMAX,NUMVG) =',//,11X,F10.5,I5,5X,F10.5,I5,//)
    9 FORMAT(1H ,'*** NR EXCEEDS DIMENSIONS OF ASX, ASY, ASZ',I5,3F10.4)
   10 FORMAT(1H ,'*** NG EXCEEDS DIMENSIONS OF AKX, AKY, AKZ',I5,3F10.4)
   11 FORMAT(1H ,10X,'NUMR',I4,' NUMG',I4,//)


     
      IF (NOVCGN.EQ.0) GO TO 32
      WRITE(6,6)
      
C      PRIMITIVE VECTORS (BKX, BKY, BKZ) OF RECIPROCAL SPACE
      
      DO 20 I=1,3
      I1=1+MOD(I,3)
      I2=1+MOD(I,3)
      CALL CROSS(BSX(I1),BSY(I1),BSZ(I1),BSX(I2),BSY(I2),BSZ(I2),
     1BKX(I),BKY(I),BKZ(I))
      VOL=DABS(BSX(1)*BKY(1)+BSY(1)*BKZ(1))
   20 CONTINUE
      
      DO 21 I=1,3
      BKX(I)=BKX(I)*VOL*TWOPI
      BKY(I)=BKY(I)*VOL*TWOPI
      BKZ(I)=BKZ(I)*VOL*TWOPI
   21 WRITE(6,3) BKX(I),BKY(I),BKZ(I)

C
C CALCULATE RADII RA, GA OF SPHERES HOLDING ALL VECTORS USED IN LAT-
C TICE SUMS. R1 IS LONGEST BASIS VECTOR. G1 IS LONGEST VECTOR IN
C BRILLOUIN ZONE. MUST BE RECONSIDERED IN ANY NEW APPLICATIONS
C
      R1 = 1.E-06
      DO 35 IQ=1,NQ
      PQX = QX(IQ)
      PQY = QY(IQ)
      PQZ = QZ(IQ)
      DO 35 JQ=1,NQ
      X = PQX - QX(JQ)
      Y = PQY - QY(JQ)
      Z = PQZ - QZ(JQ)
      DQ = DSQRT(X*X + Y*Y + Z*Z)
      IF (DQ .LT. R1) GO TO 35
      R1 = DQ
   35 CONTINUE
      R1 = R1 * 1.001
      RA = RMAX + R1
      B1 = BKX(1) + BKX(2) + BKX(3)
      B2 = BKY(1) + BKY(2) + BKY(3)
      B3 = BKZ(1) + BKZ(2) + BKZ(3)
      G1 = DSQRT(B1*B1 + B2*B2 + B3*B3) / 2.D00
      GA = GMAX + G1
      IF (LAT.EQ.3) GA = GMAX + 6.2832
      IF (LAT.EQ.8) GA = GMAX + 6.52
      IF (LAT.EQ.6) GA = GMAX + DSQRT(0.5 + (1./COA)**2) * 6.29
      WRITE(6,7) R1, RA, G1, GA


      
      DO 36 I=1,3
      DD(I)=DSQRT(BSX(I)**2+BSY(I)**2+BSZ(I)**2)
   36 DK(I)=DSQRT(BKX(I)**2+BKY(I)**2+BKZ(I)**2)
      DDM=DMAX1(DD(1),DD(2),DD(3))
      DKM=DMAX1(DK(1),DK(2),DK(3))
      DDM=TWOPI/DDM
      DKM=TWOPI/DKM
      NUMR=2*(IFIX(RA/DKM)+1)+1
      NUMG=2*(IFIX(GA/DDM)+1)+1
      NUMRH=NUMR/2+1
      NUMGH=NUMG/2+1
      WRITE(6,11) NUMR, NUMG
C
C REAL SPACE
C
      WRITE(6,4)
      NR=0
      NRO=0
      DO 22 L=1,NUMR
   

      A=L-NUMRH
      DO 22 M=1,NUMR
      B=M-NUMRH
      DO 22 N=1,NUMR
      C=N-NUMRH
      SX=A*BSX(1)+B*BSX(2)+C*BSX(3)
      SY=A*BSY(1)+B*BSY(2)+C*BSY(3)
      SZ=A*BSZ(1)+B*BSZ(2)+C*BSZ(3)
      DX=DSQRT(SX*SX+SY*SY+SZ*SZ)
      IF (DX.GT.RA) GO TO 22
      IF (DX.LE.RMAX) NRO=NRO+1
      NR=NR+1
      IF (NR.GT.500) GO TO 33
      D(NR)=DX
      CSX(NR)=SX
      CSY(NR)=SY
      CSZ(NR)=SZ
   22 CONTINUE
C
C SORT VECTORS IN ORDER OF INCREASING D
C

      DA=1.D-06
      NSH=0
      NSHL=-1
      DO 23 K=1,NR
      AMIN=1000.
      DO 24 N=1,NR
      IF (D(N)-AMIN) 25, 24, 24
   25 AMIN=D(N)
      N1=N
   24 CONTINUE
      NSHL=NSHL+1
      ASX(K)=CSX(N1)
      ASY(K)=CSY(N1)
      ASZ(K)=CSZ(N1)
      DB=D(N1)
      DR(K)=DB
      IF (DB .GT. DA+1.D-06) GO TO 26
      WRITE(6,2)K, ASX(K), ASY(K), ASZ(K), DB
      GO TO 23
   26 NSH=NSH+1
      WRITE(6,1) NSH, NSHL
      NSR(NSH)=NSHL
      WRITE(6,2)K, ASX(K), ASY(K), ASZ(K), DB
      NSHL=0
      DA=DB
   23 D(N1)=1000.
      NSH=NSH+1
      NSHL=NSHL+1
      NSR(NSH)=NSHL
      WRITE(6,1) NSH, NSHL
      NUMVR=NR
      NSHLR=NSH
 
c      
C RECIPROCAL SPACE
C

      WRITE(6,5)
      NG=0
      DO 27 L=1,NUMG
      A=L-NUMGH
      DO 27 M=1,NUMG
      B=M-NUMGH
      DO 27 N=1,NUMG
      C=N-NUMGH
      GX=A*BKX(1)+B*BKX(2)+C*BKX(3)
      GY=A*BKY(1)+B*BKY(2)+C*BKY(3)
      GZ=A*BKZ(1)+B*BKZ(2)+C*BKZ(3)
      DX=DSQRT(GX*GX+GY*GY+GZ*GZ)
      IF (DX .GT. GA) GO TO 27
      NG=NG+1
      IF (NG .GT. 300) GO TO 34
      D(NG)=DX
      CSX(NG)=GX
      CSY(NG)=GY
      CSZ(NG)=GZ
   27 CONTINUE
C
C SORT VECTORS IN ORDER OF INCREASING D
C
  
      DA=1.E-06
      NSH=0
      NSHL=-1
      DO 28 K=1,NG
      AMIN=1000.
      DO 29 N=1,NG
      IF (D(N)-AMIN) 30, 29, 29 
   30 AMIN=D(N)
      N1=N
   29 CONTINUE
      NSHL=NSHL+1
      AKX(K)=CSX(N1)
      AKY(K)=CSY(N1)
      AKZ(K)=CSZ(N1)
      DB=D(N1)
      IF (DB.GT.DA+1.D-07) GO TO 31
      WRITE(6,2) K, AKX(K), AKY(K), AKZ(K), DB
      GO TO 28
   31 NSH=NSH+1
      WRITE(6,1) NSH, NSHL
      WRITE(6,2) K, AKX(K), AKY(K), AKZ(K), DB
      NSG(NSH)=NSHL
      NSHL=0
      DA=DB
   28 D(N1)=1000.
      NSH=NSH+1
      NSHL=NSHL+1
      NSG(NSH)=NSHL
      WRITE(6,1) NSH, NSHL
      NUMVG=NG
      NSHLG=NSH
C
C       STORE VECTORS ON FILE 1
C      

      WRITE(1) BKX,BKY,BKZ,VOL,RMAX,GMAX,NR,NG,NRO
      WRITE(1)(ASX(N),N=1,NR)
      WRITE(1)(ASY(N),N=1,NR)
      WRITE(1)(ASZ(N),N=1,NR)
      WRITE(1)(DR(N), N=1,NR)
      WRITE(1)(AKX(N),N=1,NG)
      WRITE(1)(AKY(N),N=1,NG)
      WRITE(1)(AKZ(N),N=1,NG)
      RETURN
   32 continue

c     READ VECTORS GENERATED IN AN EARLIER RUN
      READ(1) BKX,BKY,BKZ,VOL,RMAX,GMAX,NUMVR,NUMVG,NRO
      READ(1)(ASX(N),N=1,NUMVR)
      READ(1)(ASY(N),N=1,NUMVR)
      READ(1)(ASZ(N),N=1,NUMVR)
      READ(1)(DR(N),N=1,NUMVR)
      READ(1)(AKX(N),N=1,NUMVG)
      READ(1)(AKY(N),N=1,NUMVG)
      READ(1)(AKZ(N),N=1,NUMVG)
      WRITE(6,8) RMAX,NUMVR,GMAX,NUMVG
      RETURN
   33 WRITE(6,9) NR,DX,RA,RMAX
      STOP
   34 WRITE(6,10)NG,DX,GA,GMAX
      STOP
      END


      SUBROUTINE SMTRX(PKXP,PKYP,PKZP)
