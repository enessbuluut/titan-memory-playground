#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif



int global_init = 42;  //.data
int global_uninit;      //.bss

static int static_init = 3; //.data
static int static_uninit;  //.bss

void text_func(void) {    //.text
    puts("text_func çağırıldı.");
}

static unsigned long get_process_id(void){
    #ifdef _WIN32
        return (unsigned long)GetCurrentProcessId();
    #else
        return (unsigned long)getpid();
    #endif
}

int main(void){
    int local_var = 145;  //stack
    int *heap_ptr = malloc(sizeof(int));  // heap_ptr stack üzerinde, *heap_ptr heap bölgesinde

    if (heap_ptr==NULL){
        perror("malloc başarısız.");
        return 1;
    }

    *heap_ptr=999;

    const char *msg = "Titan Memory Playground"; // string literal -> .rodata ama msg stackte'dir.

    printf("PID              : %ld\n", get_process_id());
    printf("global_init      : %p\n", (void *)&global_init);
    printf("global_uninit    : %p\n", (void *)&global_uninit);
    printf("static_init      : %p\n", (void *)&static_init);
    printf("static_uninit    : %p\n", (void *)&static_uninit);
    printf("local_var        : %p\n", (void *)&local_var);
    printf("heap target      : %p\n", (void *)heap_ptr);
    printf("heap_ptr itself  : %p\n", (void *)&heap_ptr);
    printf("string literal   : %p\n", (void *)msg);
    printf("msg pointer      : %p\n", (void *)&msg);
    printf("text_func        : %p\n", (void *)text_func);

#ifndef CI_MODE
    printf ("\nProgram duraklatildi. /proc/<pid>/maps veya pmap ile inceleme yapılabilir \n");
    printf("Devam etmek için enter tuşuna basınız...\n");
    getchar();
#endif

    free(heap_ptr);
    return 0;
}
