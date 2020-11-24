#include <iostream>
#include <ctime>
#include <cstdlib>
#include <iomanip>
#include <cmath>
#include <typeinfo>
#include <fstream>
using namespace std;

#define FILTER_SIZE 5
#define IMAGE_SIZE 10
#define PADDING 2

void convGausian(double[][FILTER_SIZE], int[][IMAGE_SIZE + 2*PADDING], double[][IMAGE_SIZE], int, int);
void basicConvGausian(double[][FILTER_SIZE], double**, double&, int);
void caculateRMSE(double[][IMAGE_SIZE], int[][IMAGE_SIZE], int, double&);
void dumpTest(double[][FILTER_SIZE], int[][IMAGE_SIZE], int, int, int);
void dumpAnswer(double[][IMAGE_SIZE], int, double);

int main(){
    srand(time(NULL));
    const int filter_size = FILTER_SIZE;
    double G_filter[filter_size][filter_size] = {
        {0.0039, 0.0156, 0.0234, 0.0156, 0.0039},
        {0.0156, 0.0625, 0.0938, 0.0625, 0.0156},
        {0.0234, 0.0938, 0.1408, 0.0938, 0.0234},
        {0.0156, 0.0625, 0.0938, 0.0625, 0.0156},
        {0.0039, 0.0156, 0.0234, 0.0156, 0.0039}
    };

    const int padding = PADDING;
    const int image_size = IMAGE_SIZE; 
    const int image_padding_size = IMAGE_SIZE + 2*PADDING;
    int image[image_size][image_size];
    int image_pad[image_padding_size][image_padding_size];
    double output[image_size][image_size];
    double rmse = 0.0;

    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            image[i][j] = rand()%200;
        }
    }
    for(int i=0; i<image_padding_size; i++){
        for(int j=0; j<image_padding_size; j++){
            if(i<padding || i>=image_padding_size-padding || j<padding || j>=image_padding_size-padding) image_pad[i][j] = 0;
            else image_pad[i][j]= image[i-2][j-2];
        }
    }
    convGausian(G_filter, image_pad, output, filter_size, image_padding_size);

    cout<<"input\n";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            cout<<setw(3)<<image[i][j]<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";

    cout<<"output in double\n";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            cout<<setw(6)<<output[i][j]<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";

    cout<<"output in int(rounded)\n";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            cout<<setw(3)<<round(output[i][j])<<" ";
        }
        cout<<"\n";
    }
    cout<<"\n";
    caculateRMSE(output, image, image_size, rmse);
    dumpTest(G_filter, image, filter_size, image_size, padding);
    dumpAnswer(output, image_size, rmse);
    return 0;
}

void convGausian(double G_filter[][FILTER_SIZE], int image[][IMAGE_SIZE+2*PADDING], double output[][IMAGE_SIZE], int filter_size, int image_size){
    for(int xidx=0; xidx<image_size-filter_size+1; xidx++){
        for(int yidx=0; yidx<image_size-filter_size+1; yidx++){
            double** kernelToCompute = new double*[filter_size];
            for(int i=0; i<filter_size; i++){
                double* row = new double [filter_size];
                for(int j=0; j<filter_size; j++){
                    row[j] = (double)image[xidx+i][yidx+j];
                    cout<<row[j]<<" ";
                }
                cout<<"\n";
                kernelToCompute[i] = row;
            }
            basicConvGausian(G_filter, kernelToCompute, output[xidx][yidx], filter_size);
            for(int i=0; i<filter_size; i++){
                delete []kernelToCompute[i];
            }
            delete []kernelToCompute;
        }
    }
}

void basicConvGausian(double G_filter[][FILTER_SIZE], double** kernelToCompute, double& output, int filter_size){
    double convSum = 0.0;
    for(int i=0; i<filter_size; i++){
        for(int j =0; j<filter_size; j++) convSum += G_filter[i][j]*kernelToCompute[i][j];
    }
    output = convSum;
}

void caculateRMSE(double output[][IMAGE_SIZE], int image[][IMAGE_SIZE], int image_size, double &rmse){
    double sum = 0.0;
    double data_num = (double) image_size*image_size;
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            sum += (double) (int(round(output[i][j])) - image[i][j])*(int(round(output[i][j])) - image[i][j]);
        }
    }
    rmse = sqrt(sum/data_num);
}

void dumpTest(double G_filter[][FILTER_SIZE], int image[][IMAGE_SIZE], int filter_size, int image_size, int padding){
    fstream file;
    file.open("test_data.txt", ios::out);
    file<<"data_i: .dword ";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            file<<to_string(image[i][j])<<", ";
        }
        file<<'\n';
    }
    file<<'\n';
    file<<"data_o: .dword 0:"<<to_string(image_size*image_size)<<'\n';
    file<<"data_pad: .dword 0:"<<to_string((image_size+2*padding)*(image_size+2*padding))<<'\n';
    file<<"data_size: .dword "<<to_string(image_size)<<", "<<to_string(image_size)<<'\n';
    file<<"kernel_5: ";
    for(int i=0; i<filter_size; i++){
        file<<".double ";
        for(int j=0; j<filter_size-1; j++){
            file<<to_string(G_filter[i][j])<<", ";
        }
        file<<to_string(G_filter[i][filter_size-1])<<'\n';
    }
    file.close();
}

void dumpAnswer(double output[][IMAGE_SIZE], int image_size, double rmse){
    fstream file;
    file.open("ans.txt", ios::out);
    file<<"before rounding:\n";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            file<<output[i][j]<<" ";
        }
        file<<'\n';
    }
    file<<"\n\nafter rounding:\n";
    for(int i=0; i<image_size; i++){
        for(int j=0; j<image_size; j++){
            file<<setw(3)<<int(round(output[i][j]))<<" ";
        }
        file<<'\n';
    }
    file<<"\n\nrmse: "<<rmse<<'\n';
    file.close();
}