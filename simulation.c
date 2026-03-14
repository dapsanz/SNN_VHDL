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

// Helper function to simulate hardware BRAM/File loading
void load_file(const char* filename, void* buffer, size_t size) {
    FILE* f = fopen(filename, "rb");
    if (!f) {
        printf("Error: Could not open %s. Make sure to export them from Python first!\n", filename);
        exit(1);
    }
    fread(buffer, 1, size, f);
    fclose(f);
}

int main() {
    // --- 1. MEMORY ALLOCATION ---
    int8_t   w_ih[INPUT_SIZE * HIDDEN_SIZE];      // 784 blocks of 128 weights
    int8_t   w_ho[HIDDEN_SIZE * OUTPUT_SIZE];     // 128 blocks of 10 weights
    uint8_t  image_buffer[INPUT_SIZE];            // Raw pixel data (0-255)
    
    int16_t  v_hidden[HIDDEN_SIZE] = {0};         // Membrane Potentials
    int16_t  v_output[OUTPUT_SIZE] = {0};         
    uint8_t  spike_counts[OUTPUT_SIZE] = {0};     

    srand(time(NULL)); // For Rate-Encoding randomness

    // --- 2. LOAD DATA ---
    load_file("weights_ih_transposed.bin", w_ih, sizeof(w_ih));
    load_file("weights_ho_transposed.bin", w_ho, sizeof(w_ho));
    load_file("test_image_label_1.bin", image_buffer, sizeof(image_buffer));

    printf("Inference started for 16 time steps...\n");

    // --- 3. TEMPORAL SIMULATION ---
    for (int t = 0; t < TIME_STEPS; t++) {    
        // --- PHASE A: Input Layer -> Hidden Layer ---
        for (int p = 0; p < INPUT_SIZE; p++) {
            // Rate encoding: Spike if Pixel Val > Random
            if (image_buffer[p] > (rand() % 256)) {        
                // Address logic: weight_addr = p * 128 + h
                // In VHDL, this is: weight_addr <= p & h_cntr;
                int pixel_offset = p * HIDDEN_SIZE; 
                for (int h = 0; h < HIDDEN_SIZE; h++) {
                    v_hidden[h] += w_ih[pixel_offset + h];
                }
            }
        }

        // --- PHASE B: Hidden Layer Leak & Fire ---
        for (int h = 0; h < HIDDEN_SIZE; h++) {
            // Leak: V = V - (V >> 1)
            v_hidden[h] -= (v_hidden[h] >> 1);

            if (v_hidden[h] >= THRESHOLD) {
                int hidden_neuron_offset = h * OUTPUT_SIZE;
                for (int o = 0; o < OUTPUT_SIZE; o++) {
                    v_output[o] += w_ho[hidden_neuron_offset + o];
                }
                v_hidden[h] = 0; 
            }
        }

        // --- PHASE C: Output Layer Leak & Fire ---
        // This increments the final counters (Classification)
        for (int o = 0; o < OUTPUT_SIZE; o++) {
            v_output[o] -= (v_output[o] >> 1); // Leak

            if (v_output[o] >= THRESHOLD) {
                spike_counts[o]++; // En_cd(o) in VHDL
                v_output[o] = 0;   // Reset
            }
        }
    }

    // --- 4. RESULT (Winner-Take-All) ---
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

    return 0;
}