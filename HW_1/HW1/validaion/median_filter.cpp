#include<iostream>
#include<fstream>
#include<string>
#include<ctime>
#include<cstdlib>
using namespace std;

int** medium_filter(int**, int, int, int);
int get_medium(int*, int);
void dump_test_data(int**, int, int, int);
void dump_ans(int**, int, int);

int main(){
    srand(time(NULL));
    int dim_x, dim_y = 0;
    int kernel_size = 0;
    cout<<"input dimension(x, y)..."<<endl;
    cin>>dim_x>>dim_y;
    // cout<<"input kernel size..."<<endl;
    // cin>>kernel_size;
    kernel_size = 3;

    int** x = new int*[dim_x];
    for(int i=0; i<dim_x; i++){
        int* y = new int[dim_y];
        for(int j=0; j<dim_y; j++){
            y[j] = rand()%256;
        }
        x[i] = y;
    }

    printf("Before filter...\n");
    for(int i=0;i<dim_x;i++){
        for(int j=0; j<dim_y; j++) printf("%d ", x[i][j]);
        printf("\n");
    }
    dump_test_data(x, dim_x, dim_y, kernel_size);
    printf("====================================\nAfter filter...\n");

    if(kernel_size>=dim_x || kernel_size>=dim_y){
        for(int i=0;i<dim_x;i++){
            for(int j=0; j<dim_y; j++) printf("%d ", x[i][j]);
            printf("\n");
        }
        dump_ans(x, dim_x, dim_y);
    }
    else{
        int** out = medium_filter(x, dim_x, dim_y, kernel_size); //get the filtered array
        for(int i=0;i<dim_x-kernel_size+1;i++){
            for(int j=0; j<dim_y-kernel_size+1; j++) printf("%d ", out[i][j]);
            printf("\n");
        }
        dump_ans(out, dim_x-kernel_size+1, dim_y-kernel_size+1);
        for(int i=0; i<dim_x-kernel_size+1; i++){
            delete []out[i];
        }
        delete []out;
    }

    for(int i=0; i<dim_x; i++){
        delete []x[i];
    }
    delete []x;

    printf("Process completed...\n");
    return 0;
}

int** medium_filter(int** x, int dim_x, int dim_y, int kernel_size){
    if(kernel_size>=dim_x || kernel_size>=dim_y || kernel_size==0){
        return x;
    }
    else{
        int new_xdim = dim_x-kernel_size+1;
        int new_ydim = dim_y-kernel_size+1;
        int** out = new int*[new_xdim];
        for(int x_idx=0; x_idx<new_xdim; x_idx++){
            int* row = new int[new_ydim];
            for(int y_idx=0; y_idx<new_ydim; y_idx++){

                int* in = new int[kernel_size*kernel_size];
                // cout<<"create"<<endl;
                for(int i=0; i<kernel_size; i++){
                    for(int j=0; j<kernel_size; j++){
                        in[i*kernel_size+j] = x[x_idx+i][y_idx+j];
                    }
                }

                *(row+y_idx) = get_medium(in, kernel_size*kernel_size);
                // cout<<*(row+y_idx)<<endl;

                delete []in;
            }
            *(out+x_idx) = row;
        }
        return out;
    }
}
int get_medium(int* in, int size){
    // cout<<"in get medium"<<endl;
    for(int i=0; i<size-1; i++){
        for(int j=0; j<size-1-i; j++){
            if(in[j]>in[j+1]){
                int temp = in[j];
                in[j] = in[j+1];
                in[j+1] = temp;
            }
        }
        // cout<<"i: "<<i<<endl;
    }
    // cout<<"out get medium"<<endl;
    return (size%2 == 0) ? (in[size/2-1]+in[size/2])/2 : in[size/2];
}

void dump_test_data(int** x, int dim_x, int dim_y, int kernel_size){
    fstream file;
    file.open("data.txt", ios::out);

    //write scope
    file<<"# "<<to_string(dim_x)<<"*"<<to_string(dim_y)<<" "<<to_string(kernel_size)<<"\n";
    //write data_i
    file<<"data_i: ";
    for(int x_idx=0; x_idx<dim_x; x_idx++){
        file<<".dword ";
        for(int y_idx=0; y_idx<dim_y-1; y_idx++){
            file<<to_string(x[x_idx][y_idx])<<", ";
        }
        file<<to_string(x[x_idx][dim_y-1])<<"\n";
    }
    //write data_o
    int out_size = (dim_x-kernel_size+1)*(dim_y-kernel_size+1);
    file<<"data_o: .dword 0:"<<to_string(out_size)<<'\n';
    //write data_size
    file<<"data_size: .dword "<<to_string(dim_x)<<", "<<to_string(dim_y)<<'\n';
    //write buffer
    file<<"buffer: .dword 0:"<<to_string(kernel_size*kernel_size)<<'\n';
    file.close();
}

void dump_ans(int** out, int new_xdim, int new_ydim){
    // cout<<new_xdim<<" "<<new_ydim;
    fstream file;
    file.open("ans1.txt", ios::out);
    for(int x_idx=0; x_idx<new_xdim; x_idx++){
        for(int y_idx=0; y_idx<new_ydim; y_idx++){
            file<<to_string(out[x_idx][y_idx])<<" ";
        }
        file<<"\n";
    }
    file.close();
}