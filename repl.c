#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <editline/readline.h>
#include <editline/history.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdint.h>

typedef struct{
    char* buffer;
    size_t buffer_length;
    ssize_t input_length;
}InputBuffer;

typedef enum{
    META_COMMAND_SUCCESS,
    META_COMMAND_UNRECOGNIZED_COMMAND
}MetaCommandResult;

typedef enum{
    PREPARE_SUCCESS,
    PREPARE_UNRECOGNIZED_STATMENT
}PrepareResult;

typedef enum{
    STATEMENT_INSERT,
    STATEMENT_SELECT
}StatementType;

typedef struct{
    StatementType type;
}Statement;

InputBuffer* new_input_buffer(){
    InputBuffer* input_buffer=(InputBuffer*)malloc(sizeof(InputBuffer));
    input_buffer->buffer=NULL;
    input_buffer->buffer_length=0;
    input_buffer->input_length=0;
    return input_buffer;
}

MetaCommandResult do_meta_command(InputBuffer* input_buffer){
    printf("%s\n",input_buffer->buffer);
    if(strcmp(input_buffer->buffer,".exit")==0){
        exit(EXIT_SUCCESS);
    }else{
        return META_COMMAND_UNRECOGNIZED_COMMAND;
    }
}
//void print_prompt(){printf("db > ");}

PrepareResult prepare_statement(InputBuffer* input_buffer,Statement* statement){
    if(strncmp(input_buffer->buffer,"insert",6)==0){
        statement->type=STATEMENT_INSERT;
        return PREPARE_SUCCESS;
    }
    if(strcmp(input_buffer->buffer,"select")==0){
        statement->type=STATEMENT_SELECT;
        return PREPARE_SUCCESS;
    }
    return PREPARE_UNRECOGNIZED_STATMENT;
}

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

void execute_statement(Statement* statement){
    switch(statement->type){
        case(STATEMENT_INSERT):
            printf("This is where we would do an insert.\n");
            break;
        case(STATEMENT_SELECT):
            printf("This is where we would do a select.\n");
            break;
    }
}

int main(int argc,char* argv[])
{
    InputBuffer* input_buffer=new_input_buffer();
    while(true){
//        print_prompt();
        read_input(input_buffer);
        if(input_buffer->buffer[0]=='.'){
            switch(do_meta_command(input_buffer)){
                case (META_COMMAND_SUCCESS):
                    continue;
                case (META_COMMAND_UNRECOGNIZED_COMMAND):
                    printf("Unrecognized command '%s'\n",input_buffer->buffer);
                    continue;
            }
        }

        Statement statement;
        switch(prepare_statement(input_buffer,&statement)){
            case(PREPARE_SUCCESS):
                break;
            case(PREPARE_UNRECOGNIZED_STATMENT):
                printf("Unrecognized keyword at start of '%s'.\n",
                       input_buffer->buffer);
                continue;
        }

        execute_statement(&statement);
        printf("Executed.\n");

    }
    return 0;
}

