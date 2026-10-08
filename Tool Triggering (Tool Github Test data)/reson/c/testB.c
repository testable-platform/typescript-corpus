#include <stdio.h>

void print_hello_test_b1() {
    printf("Hello, World!\n");
    for (int i = 0; i < 5; i++) {
        printf("This is line %d\n", i);
        if (i % 2 == 0) {
            printf("Even number\n");
        } else {
            printf("Odd number\n");
        }
    }
}

void print_hello_test_b2() {
    printf("Hello, World!\n");
    for (int i = 0; i < 5; i++) {
        printf("This is line %d\n", i);
        if (i % 2 == 0) {
            printf("Even number\n");
        } else {
            printf("Odd number\n");
        }
    }
}

int main() {
    print_hello_test_b1();
    print_hello_test_b2();
    return 0;
}