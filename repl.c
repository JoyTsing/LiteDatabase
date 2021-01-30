#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <editline/readline.h>
#include <editline/history.h>

typedef struct{
    char* buffer;
    size_t buffer_length;
    ssize_t input_length;
}InputBuffer;

InputBuffer* new_input_buffer(){
    InputBuffer* input_buffer=(InputBuffer*)malloc(sizeof(InputBuffer));
    input_buffer->buffer=NULL;
    input_buffer->buffer_length=0;
    input_buffer->input_length=0;
    return input_buffer;
}

//void print_prompt(){printf("db > ");}

void read_input(InputBuffer* input_buffer){
//    ssize_t bytes_read=
//        getline(&(input_buffer->buffer),&(input_buffer->buffer_length),stdin);
    input_buffer->buffer=(char*)malloc(sizeof(char)*input_buffer->buffer_length);
    input_buffer->buffer=readline("db > ");
    if(input_buffer->buffer==NULL){
        printf("Error reading input\n");
        exit(EXIT_FAILURE);
    }
    add_history(input_buffer->buffer);
    input_buffer->input_length=strlen(input_buffer->buffer);
}

void close_input_buffer(InputBuffer* input_buffer){
    free(input_buffer->buffer);
    free(input_buffer);
}

int main(int argc,char* argv[])
{
    InputBuffer* input_buffer=new_input_buffer();
    while(true){
//        print_prompt();
        read_input(input_buffer);
        if(strcmp(input_buffer->buffer,".exit")==0){
            close_input_buffer(input_buffer);
            exit(EXIT_SUCCESS);
        }else{
            printf("Unrecognized command '%s'.\n",input_buffer->buffer);
        }
    }
    return 0;
}

