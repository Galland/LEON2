/*
 * Copyright (C) 2000 Rudolf Matousek <matousek@utia.cas.cz>
 *
 * This code may be used under the terms of Version 2 of the GPL,
 * read the file COPYING for details.
 *
 */

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <getopt.h>

/* This values are set by default. */

#define TMPL "tmpl.vhdl"
#define AW "10"
#define DW "8"
#define EN "ROM"
#define ON "rom.vhdl"
#define TF "./tmp"

void newline(FILE *infile, FILE *outfile)
{
  int chr;
  while((chr=fgetc(infile))!=EOF){
    fputc(chr,outfile);
    if(chr=='\n')
      break;
  }
}

int pw(int nr)
{
  int i,r=1;
  for(i=0;i<nr-1;i++){
    r<<=1;
    r|=1;
  }
  return r;
}

char *int2bin(int bits, int nr, char *buf)
{
  int i;
  for(i=bits-1;i>=0;i--){
    buf[i]=(nr&1) ? '1' : '0';
    nr>>=1;
  }
  return buf;
}

void create_data(FILE *bitfile, FILE *outfile, int a, int dw)
{
  int i,j,c,ca;
  char buf[1024], x[32];
  ca = pw(a);
  for(j=0;j<=ca;j++){
    int2bin(a,j,x);
    for(i=0; i<dw/8; i++)
      if((c=fgetc(bitfile))!=EOF)
	int2bin(8,c,buf+i*8);
      else
	int2bin(8,0,buf+i*8);
    buf[dw]=0; x[a] = 0;
    fprintf(outfile,"    when \"%s\" => d <= \"%s\";\n",x,buf);
    if (feof(bitfile)) break;
  }
//  fseek(outfile,-6,SEEK_CUR);
}

void print_help()
{
  printf("\nSyntesible VHDL rom IP core creator. By Rudolf Matousek (UTIA/SP).\n\n");
  printf("rom2vhdl [-a <int>] [-d <int>]");
  printf(" [-e <string>] [-t <string>]\n");
  printf("\t[-o <output>] <input_binary_name>\n");
  printf("rom2vhdl -h\n\n");
  printf("-a -- address bus width (8 by default)\n");
  printf("-d -- data bus width (8 by default)\n");
  printf("-e -- VHDL entity name (\"ROM\" by default)\n");
  printf("-t -- VHDL template file name (\"/usr/local/share/rom2vhdl/tmpl.vhdl\" by default)\n");
  printf("-o -- output file name (rom.vhdl by default)\n");
  printf("-h -- this help\n\n");
  printf("input_binary_name -- (required) rom contents\n\n");
}

int main(int argc, char **argv)
{
  FILE *infile, *outfile, *bitfile;
  int c,a,d,cin;
  char tmpl[1024];
  char aw[256];
  char dw[256];
  char en[1024];
  char on[1024];
  char ib[1024];
  char buf[4096];

  int this_option_optind = optind ? optind : 1;
  int option_index = 0;

  strcpy(tmpl,TMPL);
  strcpy(aw,AW);
  strcpy(dw,DW);
  strcpy(en,EN);
  strcpy(on,ON);
  
  opterr=0;

  while(1){
    c=getopt(argc,argv,"t:a:d:e:o:h");
    if (c == -1)
      break;
    
    switch (c){
    case 'h':
      print_help();
      exit(0);
    case 'a':
      strcpy(aw,optarg);
      break;
    case 'd':
      strcpy(dw,optarg);
      break;
    case 'o':
      strcpy(on,optarg);
      break;
    case 'e':
      strcpy(en,optarg);
      break;
    case 't':
      strcpy(tmpl,optarg);
      break;
    default:
      printf("Illegal option.\n");
      printf("Use rom2vhdl --help (or -h) for help.\n");
      return -1;
    };
  };
  
  if(optind<argc){
    strcpy(ib,argv[optind]);
  }
  else{
    printf("Input binary name missing.\n");
    printf("Use rom2vhdl --help (or -h) for help.\n");
    return -1;
  }

/*    printf("tmpl: %s\n",tmpl); */
/*    printf("aw: %s\n",aw); */
/*    printf("dw: %s\n",dw); */
/*    printf("en: %s\n",en); */
/*    printf("on: %s\n",on); */
/*    printf("ib: %s\n",ib); */

  sscanf(aw,"%d",&a);
  sscanf(dw,"%d",&d);

//  if((d%8)){
//  printf("Data width must be power of 8.\n");
//    return -1;
//  }

  if(!(bitfile=fopen(ib,"r"))){
    perror(ib);
    return -1;
  };

  if(!(infile=fopen(tmpl,"r"))){
    perror(tmpl);
    fclose(bitfile);
    return -1;
  };

  if(!(outfile=fopen(on,"w"))){
    perror(on);
    fclose(bitfile);
    fclose(infile);
    return -1;
  };

  d = 32;

  while((cin=fgetc(infile))!=EOF){
    if(cin=='-'){
      fputc(cin,outfile);
      cin=fgetc(infile);
      if(cin=='-'){
	fputc(cin,outfile);
	newline(infile,outfile);
	continue;
      }
    }
    if(cin=='$'){
      cin=fgetc(infile);
      switch(cin){
      case 'a':
	fprintf(outfile,"%d",a-1);
	break;
      case 'd':
	fprintf(outfile,"%d",d-1);
	break;
      case 'n':
	fprintf(outfile,"%d",pw(a));
	break;
      case 'e':
	fprintf(outfile,en);
	break;
      case 'i':
	create_data(bitfile,outfile,a,d);
	break;
      }
    }
    else{
      fputc(cin,outfile);
    }
  }

  fclose(infile);
  fclose(outfile);

  return 0;
}



