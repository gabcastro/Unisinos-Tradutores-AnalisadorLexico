int main() 
{ 
    int v[] = {5, 10, 15, 3, 10, 76, 5, 13, 33, 45}; 
    int * pt; 
    int i; 
      
    pt = v; //Atribui o endereço do vetor 
      
    AlterarVetor(v, 10); 
      
    for(int i = 0; i < 10; i++) 
    { 
        printf("V[%i] = %i\r\n", i, *(pt + i)); 
    } 
     
    CalculoMedia(); 
    VerificaNumero(); 
     
    return 0; 
}

