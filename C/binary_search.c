#include <stdint.h>
#include <stdio.h>

int n = 100;

struct {
  int key;
  int data;
} table[100];

void ini_table() {
  for (int i = 0; i < n; i++) {
    table[i].key = i;
    table[i].data = i * 123;
  }
}

int binarysearch(int key) {
  int low, middle, high;
  low = 0;
  high = n - 1;

  while (low <= high) {
    middle = (low + high) / 2;
    if (key == table[middle].key) {
      return table[middle].data;
    } else if (key < table[middle].key) {
      high = middle - 1;
    } else {
      low = middle - 1;
    }
    printf("low:%d mid:%d, high:%d\n", low, middle, high);
  }
  return -1;
}

int main(void) {
  ini_table();
  int result = binarysearch(88);
  printf("%d", result);
}
