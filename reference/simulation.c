#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>

#define INPUT_SIZE 784
#define HIDDEN_SIZE 128
#define OUTPUT_SIZE 10
#define THRESHOLD 175
#define TIME_STEPS 16  

// Helper for file loading
void load_file(const char* filename, void* buffer, size_t size) {
    FILE* f = fopen(filename, "rb");
    if (!f) {
        printf("Error: Could not open %s. \n", filename);
        exit(1);
    }
    fread(buffer, 1, size, f);
    fclose(f);
}

int main(int argc, char *argv[]) {
    
    // --- MEMORY ALLOCATION ---
    int8_t   w_ih[INPUT_SIZE * HIDDEN_SIZE];      // 784 blocks of 128 weights
    int8_t   w_ho[HIDDEN_SIZE * OUTPUT_SIZE];     // 128 blocks of 10 weights
    uint8_t  image_buffer[INPUT_SIZE];            // Raw pixel data (0-255)
    
    int16_t  v_hidden[HIDDEN_SIZE] = {0};         // Membrane Potentials
    int16_t  v_output[OUTPUT_SIZE] = {0};         
    uint8_t  spike_counts[OUTPUT_SIZE] = {0};     

    srand(time(NULL)); // For Rate-Encoding randomness
    
    // --- LOAD DATA ---
    load_file("binaries/weights_ih_transposed.bin", w_ih, sizeof(w_ih));
    load_file("binaries/weights_ho_transposed.bin", w_ho, sizeof(w_ho));
    
    char digit_char;
    // Check if an argument was provided
    if (argc > 1) {
        digit_char = argv[1][0];
    } else {
        digit_char = '0';
        load_file("binaries/test_image_label_0.bin", image_buffer, sizeof(image_buffer));
    }

    switch (digit_char) {
        case '0': load_file("binaries/test_image_label_0.bin", image_buffer, sizeof(image_buffer)); break;
        case '1': load_file("binaries/test_image_label_1.bin", image_buffer, sizeof(image_buffer)); break;
        case '2': load_file("binaries/test_image_label_2.bin", image_buffer, sizeof(image_buffer)); break;
        case '3': load_file("binaries/test_image_label_3.bin", image_buffer, sizeof(image_buffer)); break;
        case '4': load_file("binaries/test_image_label_5.bin", image_buffer, sizeof(image_buffer)); break;
        case '5': load_file("binaries/test_image_label_5.bin", image_buffer, sizeof(image_buffer)); break;
        case '6': load_file("binaries/test_image_label_6.bin", image_buffer, sizeof(image_buffer)); break;
        case '7': load_file("binaries/test_image_label_7.bin", image_buffer, sizeof(image_buffer)); break;
        case '8': load_file("binaries/test_image_label_8.bin", image_buffer, sizeof(image_buffer)); break;
        case '9': load_file("binaries/test_image_label_9.bin", image_buffer, sizeof(image_buffer)); break;
        default:
            printf("Invalid input '%c'. Defaulting to 0.\n", digit_char);
            break;
    }
    
    
    printf("Inference started for %d time steps...\n", TIME_STEPS);

    // --- TEMPORAL SIMULATION ---
    for (int t = 0; t < TIME_STEPS; t++) {    
        // Input Layer -> Hidden Layer 
        for (int p = 0; p < INPUT_SIZE; p++) {
            // Rate encoding: Spike if Pixel Val > Random
            if (image_buffer[p] > (rand() % 256)) {        
                // Address logic: weight_addr = p * 128 + h
                int pixel_offset = p * HIDDEN_SIZE; 
                for (int h = 0; h < HIDDEN_SIZE; h++) {
                    v_hidden[h] += w_ih[pixel_offset + h];
                }
            }
        }

        // --- Hidden Layer Leak & Fire ---
        for (int h = 0; h < HIDDEN_SIZE; h++) {
            v_hidden[h] -= (v_hidden[h] >> 1);  // Leak: V = V - (V >> 1)
            if (v_hidden[h] >= THRESHOLD) {
                int hidden_neuron_offset = h * OUTPUT_SIZE;
                for (int o = 0; o < OUTPUT_SIZE; o++) {
                    v_output[o] += w_ho[hidden_neuron_offset + o];
                }
                v_hidden[h] = 0; 
            }
        }

        // ---  Output Layer Leak & Fire ---
        for (int o = 0; o < OUTPUT_SIZE; o++) {
            v_output[o] -= (v_output[o] >> 1); // Leak
            if (v_output[o] >= THRESHOLD) {
                spike_counts[o]++; 
                v_output[o] = 0;
            }
        }
    }
    // --- RESULT (Winner-Take-All) ---
    int winner = 0;
    int max_val = -1;
    printf("\n--- Final Spike Counts ---\n");
    for (int i = 0; i < OUTPUT_SIZE; i++) {
        printf("Digit %d: %d\n", i, spike_counts[i]);
        if (spike_counts[i] > max_val) {
            max_val = spike_counts[i];
            winner = i;
        }
    }
    printf("--------------------------\n");
    printf("Hardware Prediction: %d\n", winner);
    printf("Expected Output:     %c\n", digit_char);

    return 0;
}
