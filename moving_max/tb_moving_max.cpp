#include <cstdio>
#include <climits>

#include "moving_max.h"

/* Прямий перебір
   out[n] = найбільше з in[n-7] ... in[n]; якщо n < 7, то з in[0] ... in[n].
*/
static void ref_moving_max(const int in[N_SAMPLES], int out[N_SAMPLES]) {
    for (int n = 0; n < N_SAMPLES; n++) {
        int start = (n < 7) ? 0 : (n - 7);
        int max = in[start];
        for (int i = start + 1; i <= n; i++)
            if (in[i] > max) max = in[i];
        out[n] = max;
    }
}

static int run_test(const char* name, int in[N_SAMPLES]) {
    int out_data[N_SAMPLES];
    int out_ref[N_SAMPLES];

    moving_max(in, out_data);
    ref_moving_max(in, out_ref);

    int errors = 0;
    for (int n = 0; n < N_SAMPLES; n++) {
        if (out_data[n] != out_ref[n]) {
                printf("  [%s] MISMATCH n=%d: in=%d, data=%d, ref=%d\n",
                       name, n, in[n], out_data[n], out_ref[n]);
            errors++;
        }
    }
    printf("%-22s %s (%d errors)\n", name, errors ? "FAIL" : "PASS", errors);
    return errors;
}

int main() {
    int in[N_SAMPLES];
    int errors = 0;

    printf("moving_max testbench: N_SAMPLES=%d, WINDOW=%d\n\n", N_SAMPLES, WINDOW);

    /* 1. Зростаюча послідовність: максимум завжди поточний відлік */
    for (int n = 0; n < N_SAMPLES; n++) in[n] = n;
    errors += run_test("ascending", in);

    /* 2. Спадна послідовність: максимум завжди найстаріший у вікні,
          перевіряє, що старі відліки вчасно випадають */
    for (int n = 0; n < N_SAMPLES; n++) in[n] = N_SAMPLES - n;
    errors += run_test("descending", in);

    /* 3. Одиночний пік: має триматися рівно WINDOW відліків */
    for (int n = 0; n < N_SAMPLES; n++) in[n] = 0;
    in[N_SAMPLES / 2] = 100;
    errors += run_test("single spike", in);

    /* 4 Генератор */
    unsigned seed = 12345;
    for (int n = 0; n < N_SAMPLES; n++) {
        seed = seed * 1103515245u + 12345u;   /* простий повторюваний генератор */
        in[n] = (int)((seed >> 16) % 1000);
    }
    errors += run_test("generator", in);

    /* 5. Граничні значення int */
    for (int n = 0; n < N_SAMPLES; n++) {
        switch (n % 4) {
            case 0:  in[n] = INT_MIN; break;
            case 1:  in[n] = INT_MAX; break;
            case 2:  in[n] = -1;      break;
            default: in[n] = 0;       break;
        }
    }
    errors += run_test("int extremes", in);

    if (errors){
        printf("Test FAILED: %d помилок\n", errors);
        return 1;
    }
    else
    {
         printf("Test passed !\n");
        return 0;
    }
}
