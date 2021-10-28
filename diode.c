#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
/*
 * Implementation file for: diode
 * Generated with         : PLECS 4.5.8
 * Generated on           : 25 Oct 2021 07:37:55
 */

/* Model floating point type */
typedef double diode_FloatType;

/* Model checksum */
extern const char * const diode_checksum;

/* Model error status */
extern const char * diode_errorStatus;


/* Model sample time */
extern const double diode_sampleTime;


/*
 * Model states */
typedef struct
{
   bool diode_PM0_s;                /* diode */
} diode_ModelStates;
extern diode_ModelStates diode_X;


/* Block outputs */
typedef struct
{
   double SineWave;                 /* diode/Sine Wave */
} diode_BlockOutputs;
extern diode_BlockOutputs diode_B;

/* Block parameters */
typedef struct
{
   /* Parameter 'Amplitude' of
    *  Sine Wave Generator : 'diode/Sine Wave'
    */
   double SineWave_Amplitude;
   /* Parameter 'Bias' of
    *  Sine Wave Generator : 'diode/Sine Wave'
    */
   double SineWave_Bias;
} diode_Parameters;
extern diode_Parameters diode_P;

/* Entry point functions */
void diode_initialize(double time);
void diode_step(void);
void diode_terminate(void);

#if defined(__GNUC__) && (__GNUC__ > 4)
#   define _ALIGNMENT 16
#   define _RESTRICT __restrict
#   define _ALIGN __attribute__((aligned(_ALIGNMENT)))
#   if defined(__clang__)
#      if __has_builtin(__builtin_assume_aligned)
#         define _ASSUME_ALIGNED(a) __builtin_assume_aligned(a, _ALIGNMENT)
#      else
#         define _ASSUME_ALIGNED(a) a
#      endif
#   else
#      define _ASSUME_ALIGNED(a) __builtin_assume_aligned(a, _ALIGNMENT)
#   endif
#else
#   ifndef _RESTRICT
#      define _RESTRICT
#   endif
#   ifndef _ALIGN
#      define _ALIGN
#   endif
#   ifndef _ASSUME_ALIGNED
#      define _ASSUME_ALIGNED(a) a
#   endif
#endif
#define PLECSRunTimeError(msg) diode_errorStatus = msg
static const double diode_UNCONNECTED = 0;
static double diode_D_double[2];
static double diode_PM0_u[2] _ALIGN;
static double diode_PM0_prevU[2] _ALIGN;
static double diode_PM0_y[2] _ALIGN;
static size_t diode_PM0_topoIdx;
static char diode_PM0_withDiracs;
static const size_t PM0_D_0_0_rowPtr[] = {
   0,0,1
};
static const size_t PM0_D_0_0_colIdx[] = {
   0
};
static const double PM0_D_0_0_data[] _ALIGN = {
   -1.
};
static size_t PM0_natPreComm_0()
{
   const double * const u = diode_PM0_u;
   return 0; /* 0 */
}
static size_t PM0_natPostComm_0()
{
   const double * const u = diode_PM0_u;
   if (-u[0]-u[1] > 0)
   {
      return 1; /* 1 */
   }
   return 0; /* 0 */
}
static size_t PM0_forcedComm_0()
{
   return 0;                                /* 0 */
}
static const size_t PM0_D_0_1_rowPtr[] = {
   0,2,4
};
static const size_t PM0_D_0_1_colIdx[] = {
   0,1,0,1
};
static const double PM0_D_0_1_data[] _ALIGN = {
   -0.333333333333333204,-0.333333333333333204,-0.999999999999999667,
   3.33333333333333261e-16
};
static size_t PM0_natPreComm_1()
{
   const double * const u = diode_PM0_u;
   return 1; /* 1 */
}
static size_t PM0_natPostComm_1()
{
   const double * const u = diode_PM0_u;
   if (u[0]+u[1] >= 0)
   {
      return 0; /* 0 */
   }
   return 1; /* 1 */
}
static size_t PM0_forcedComm_1()
{
   return 1;                                /* 1 */
}
static const size_t * const PM0_D_0_rowPtr[] = {
   PM0_D_0_0_rowPtr,PM0_D_0_1_rowPtr
};
static const size_t * const PM0_D_0_colIdx[] = {
   PM0_D_0_0_colIdx,PM0_D_0_1_colIdx
};
static const double * const diode_PM0_D_0_data[] = {
   PM0_D_0_0_data,PM0_D_0_1_data
};
static size_t (*const PM0_natPreComm[2]) () = {
   PM0_natPreComm_0,PM0_natPreComm_1
};
static size_t (*const PM0_natPostComm[2]) () = {
   PM0_natPostComm_0,PM0_natPostComm_1
};
static size_t (*const PM0_forcedComm[2]) () = {
   PM0_forcedComm_0,PM0_forcedComm_1
};
static size_t diode_PM0_topologies[2]={
   0,1
};
static void diode_PM0_natComm()
{
   diode_PM0_topoIdx = PM0_natPreComm[diode_PM0_topoIdx]();
   diode_PM0_topoIdx = PM0_natPostComm[diode_PM0_topoIdx]();
}
static void diode_PM0_forcedComm()
{
   diode_PM0_topoIdx = PM0_forcedComm[diode_PM0_topoIdx]();
}
static void diode_PM0_output_0()
{
   const double * _RESTRICT D_0_data =
      _ASSUME_ALIGNED(diode_PM0_D_0_data[diode_PM0_topoIdx]);
   const size_t meterIdx[]={
      0,1
   };
   double y[2] _ALIGN;
   size_t i;
   for (i = 0; i < 2; ++i)
   {
      y[i] = 0;
      {
         const size_t *rowPtr = PM0_D_0_rowPtr[diode_PM0_topoIdx];
         const size_t *colIdx = PM0_D_0_colIdx[diode_PM0_topoIdx];
         size_t j;
         for (j = rowPtr[i]; j < rowPtr[i+1]; ++j)
            *(y+i) += D_0_data[j]*diode_PM0_u[colIdx[j]];
      }
   }
   for (i = 0; i < 2; ++i)
   {
      diode_PM0_y[meterIdx[i]] = y[i];
   }
}
static uint32_t diode_tickLo;
static int32_t diode_tickHi;
diode_BlockOutputs diode_B;
diode_Parameters diode_P = {
   /* Parameter 'Amplitude' of
    *  Sine Wave Generator : 'diode/Sine Wave'
    */
   5.,
   /* Parameter 'Bias' of
    *  Sine Wave Generator : 'diode/Sine Wave'
    */
   0.
};
diode_ModelStates diode_X _ALIGN;
const char * diode_errorStatus;
const double diode_sampleTime = 1e-11;
void diode_initialize(double time)
{
   double remainder;
   size_t i;
   diode_errorStatus = NULL;
   diode_tickHi = floor(time/(4294967296.0*diode_sampleTime));
   remainder = time - diode_tickHi*4294967296.0*diode_sampleTime;
   diode_tickLo = floor(remainder/diode_sampleTime + .5);
   remainder -= diode_tickLo*diode_sampleTime;
   if (fabs(remainder) > 1e-6*fabs(time))
   {
      diode_errorStatus =
         "Start time must be an integer multiple of the base sample time.";
   }

   /* Initialization for Sine Wave Generator : 'diode/Sine Wave' */
   diode_D_double[0] = sin(1256637061.43591714*time);
   diode_D_double[1] = cos(1256637061.43591714*time);

   /* Initialization for Subsystem : 'diode' */
   diode_X.diode_PM0_s = 0;
   diode_PM0_topoIdx = 0;
}

void diode_step(void)
{
   if (diode_errorStatus)
   {
      return;
   }

   /* Sine Wave Generator : 'diode/Sine Wave' */
   diode_B.SineWave = diode_P.SineWave_Bias + diode_P.SineWave_Amplitude *
                      (1.*diode_D_double[0] + 0.*diode_D_double[1]);

   /* Electrical model */


   /* Electrical model input */
   /* Voltage Source (Controlled) : 'diode/V' */
   diode_PM0_u[0]=diode_B.SineWave;
   /* Diode : 'diode/D1' */
   diode_PM0_u[1]=0.0259999999999999988;
   /* End of electrical model input */


   /* Commutation */
   diode_PM0_natComm();
   diode_PM0_forcedComm();

   /* Electrical model output */
   diode_PM0_output_0();
   /* End of electrical model output */

   /* End of electrical model */
   if (diode_errorStatus)
   {
      return;
   }

   /* Update for Sine Wave Generator : 'diode/Sine Wave' */
   {
      double scaling, scaledX, scaledY;
      scaling = 1. +
                (0.5 *
       (diode_D_double[0]*diode_D_double[0] + diode_D_double[1]*
       diode_D_double[1] - 1.));
      scaledX = diode_D_double[0] / scaling;
      scaledY = diode_D_double[1] / scaling;
      diode_D_double[0] = 0.999921044203816112 * scaledX +
                          0.0125660398833526057 * scaledY;
      diode_D_double[1] = -0.0125660398833526057 * scaledX +
                          0.999921044203816112 * scaledY;
   }

   /* Update for Subsystem : 'diode' */
   memcpy(diode_PM0_prevU,diode_PM0_u,2*sizeof(double));
}

int main(int argc, char** argv) {
  int i;
  diode_initialize(0.0);
  for(i=0; i<100; i++) {
    diode_step();
    printf("%g\t%g\n", diode_PM0_u[0], diode_PM0_y[1]);
  }
  return 0;
}

