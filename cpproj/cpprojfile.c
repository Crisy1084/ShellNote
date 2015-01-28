/* copy project files for msm8916 platform  */
/* auther: Ji Ang (jiang@topwise3g.com)     */
/* date: 2014.12.02                         */
/* gcc cppprojfile.c -o cpproj              */
/* cpproj [root path] [hy506] [m711] > log  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <dirent.h>
#include <sys/stat.h>

const unsigned char *proj_path[] = {"/LINUX/android/device/qcom/",
				 "/LINUX/customize/res/HW/",
				 "/LINUX/customize/res/",
				 "/LINUX/NON-HLOS/"};

const char *vendordevfile = "/LINUX/android/vendor/qcom/proprietary/common/config/device-vendor.mk";

#define NUMOFPATH 4

const char *listfile = "/LINUX/customize/res/list";

const char *dir2touch = "/LINUX/android/kernel/arch/arm/configs";
const char *dir2touch2 = "/LINUX/android/kernel/arch/arm/boot/dts/qcom";

// /media/disksda5/msm8916_tw/LINUX/android/kernel/arch/arm/boot/dts/qcom *9388*

char u_srcproj[32];
char u_dstproj[32];

char l_srcproj[32];
char l_dstproj[32];

char n_srcproj[32];
char n_dstproj[32];

inline char* strlwr( char* str )
{
	char* orig = str;
	// process the string
	for ( ; *str != '\0'; str++ )
	*str = tolower(*str);
	return orig;
}

inline char* strupr( char* str )
{
	char* orig = str;
	// process the string
	for ( ; *str != '\0'; str++ )
	*str = toupper(*str);
	return orig;
}

int comparechar(char x, char y)
{
	if (x == y) return;
	else if ((x>='a')&&(x<='z')&&(y>='A')&&(y<='Z'))
	{
		if ((x-0x20)==y) return 1;
	}
	else if ((x>='A')&&(x<='Z')&&(y>='a')&&(y<='z'))
	{
		if ((x+0x20)==y) return 1;
	}		
	return 0;
}

int replacestr(char *_str, char *src, char *dst)
{
	char *r;
	char *str = _str;
	int ir = 0;
	while (str)
	{
		r = strstr(str,src);
		if (r)
		{
			int p = (long)r-(long)str;
			int ls = strlen(src);
			int ld = strlen(dst);
			char *tempbuf = (char*)malloc(strlen(str)+strlen(dst)+strlen(src)+16);
   	
   		ir = 1;
   	
			strcpy(tempbuf,str);
			r = strstr(tempbuf,src);
			strcpy(r,dst);
			strcpy(tempbuf+p+ld,str+p+ls);
			
			strcpy(str,tempbuf);
			
			free(tempbuf);
		}
		else
			break;
		//str = r;
	}
	return ir;
}

int copy_dir(char *p, char *q, char *_srcproj, char *_dstproj)
{
	DIR *dirptr = NULL;
	struct dirent *entry;

	if (!(dirptr = opendir(p)))
	{
		printf("can not open dir :%s\n",p);
		return 1;
	}
	else
	{
		while (entry = readdir(dirptr))
		{
			int pl,ql,nl;

			if (!strcmp(entry->d_name,".")) continue;
			if (!strcmp(entry->d_name,"..")) continue;

			pl = strlen(p);
			ql = strlen(q);
			nl = strlen(entry->d_name);

			char *dirp = malloc(pl+nl+2);
			char *dirq = malloc(ql+nl+2);

			strcpy(dirq,q);
			strcat(dirq,"/");
			strcat(dirq,entry->d_name);

			strcpy(dirp,p);
			strcat(dirp,"/");
			strcat(dirp,entry->d_name);
			
			replacestr(dirq,l_srcproj,l_dstproj);
			replacestr(dirq,u_srcproj,u_dstproj);
			replacestr(dirq,n_srcproj,n_dstproj);

			if (entry->d_type==DT_DIR)
			{
				mkdir(dirq,S_IRWXU|S_IRWXG|S_IROTH|S_IXOTH);
				copy_dir(dirp,dirq,_srcproj,_dstproj);
			}
			else
			{
				struct stat stf;
				FILE *is,*os;
				char *buf = malloc(1024);

				stat(dirp,&stf);
				printf("cp: %s\n", dirq);
			
				is = fopen(dirp,"rb");
				os = fopen(dirq,"wb");
				while (fgets(buf,1024,is))
				{
					if (replacestr(buf,l_srcproj,l_dstproj))
						printf("...match: %s",buf);
					if (replacestr(buf,u_srcproj,u_dstproj))
						printf("...MATCH: %s",buf);
					if (replacestr(buf,n_srcproj,n_dstproj))
						printf("...number: %s",buf);
					fputs(buf,os);
				}
				fclose(os);
				fclose(is);
				
				free(buf);
				
				chmod(dirq, stf.st_mode);
			}

			free(dirq);
			free(dirp);
		}

		closedir(dirptr);
	}
	return 0;
}

int copyfilesindir(char *p)
{
	DIR *dirptr = NULL;
	struct dirent *entry;
	if (dirptr = opendir(p))
	{
		while (entry = readdir(dirptr))
		{
			int pl,nl;

			if (!strcmp(entry->d_name,".")) continue;
			if (!strcmp(entry->d_name,"..")) continue;

			FILE *is,*os;
			char *buf = malloc(1024);

			pl = strlen(p);
			nl = strlen(entry->d_name);

			char *dirp = malloc(pl+nl+2);
			char *dirq = malloc(pl+nl+2);

			strcpy(dirp,p);
			strcat(dirp,"/");
			strcat(dirp,entry->d_name);

			strcpy(dirq, dirp);
			char *fstr = malloc(pl+nl+2+pl+nl+2+32);

			if (replacestr(dirq,l_srcproj,l_dstproj))
			{
				is = fopen(dirp,"rt");
				os = fopen(dirq,"wt");
				while (fgets(buf,1024,is))
				{
					if (replacestr(buf,l_srcproj,l_dstproj))
						printf("...match: %s",buf);
					if (replacestr(buf,u_srcproj,u_dstproj))
						printf("...MATCH: %s",buf);
					if (replacestr(buf,n_srcproj,n_dstproj))
						printf("...number: %s",buf);
					fputs(buf,os);
				}
				fclose(os);
				fclose(is);
				printf("cp: %s\n", dirq);
			}
			else if (replacestr(dirq,u_srcproj,u_dstproj))
			{
				is = fopen(dirp,"rt");
				os = fopen(dirq,"wt");
				while (fgets(buf,1024,is))
				{
					if (replacestr(buf,l_srcproj,l_dstproj))
						printf("...match: %s",buf);
					if (replacestr(buf,u_srcproj,u_dstproj))
						printf("...MATCH: %s",buf);
					if (replacestr(buf,n_srcproj,n_dstproj))
						printf("...number: %s",buf);
					fputs(buf,os);
				}
				fclose(os);
				fclose(is);
				printf("cp: %s\n", dirq);
			}
			else if (replacestr(dirq,n_srcproj,n_dstproj))
			{
				is = fopen(dirp,"rt");
				os = fopen(dirq,"wt");
				while (fgets(buf,1024,is))
				{
					if (replacestr(buf,l_srcproj,l_dstproj))
						printf("...match: %s",buf);
					if (replacestr(buf,u_srcproj,u_dstproj))
						printf("...MATCH: %s",buf);
					if (replacestr(buf,n_srcproj,n_dstproj))
						printf("...number: %s",buf);
					fputs(buf,os);
				}
				fclose(os);
				fclose(is);
				printf("cp: %s\n", dirq);
			}
			free(fstr);
			free(buf);
		}
	}
}

int main (int argi, char *argv[])
{
	char *src_path;
	char *dst_path;
	int strl,i;

	if (argi<4)
	{
		printf("Usage:\n");
		printf("\tcpprojfile root_dir src target\n");
		printf("\tcpprojfile /media/disksda5/msm8916_tw hy506 m711\n");
		return;
	}
	
	memcpy(l_srcproj,argv[2],sizeof(l_srcproj));
	memcpy(l_dstproj,argv[3],sizeof(l_dstproj));
	l_srcproj[sizeof(l_srcproj)-1] = 0;
	l_dstproj[sizeof(l_dstproj)-1] = 0;

	// 大小写支持
	strcpy(u_srcproj,l_srcproj);
	strupr(u_srcproj);
	strlwr(l_srcproj);

	strcpy(u_dstproj,l_dstproj);
	strupr(u_dstproj);
	strlwr(l_dstproj);

	char *p = l_srcproj;
	while (((*p<'0')||(*p>'9'))&&(*p)) p++;
	if (*p) strcpy(n_srcproj,p);

	p = l_dstproj;
	while (((*p<'0')||(*p>'9'))&&(*p)) p++;
	if (*p) strcpy(n_dstproj,p);

	strl = strlen(argv[1])+strlen(proj_path[0])+128;

	src_path = malloc(strl);
	dst_path = malloc(strl);
	src_path[0] = 0;
	dst_path[0] = 0;

//	goto list_start;

	// 整个目录复制
	for (i=0;i<NUMOFPATH;i++)
	{
		DIR *dirptr = NULL;
		struct dirent *entry;
		char *p = malloc(strlen(argv[1])+128);

		strcpy(p,argv[1]);
		strcat(p,proj_path[i]);

		if (dirptr = opendir(p))
		{
		while (entry = readdir(dirptr))
		{
			if (strstr(entry->d_name,l_srcproj))
			{
				strcpy(src_path,argv[1]);
				strcat(src_path,proj_path[i]);
				strcat(src_path,entry->d_name);
				strcpy(dst_path,src_path);
				if (replacestr(dst_path,l_srcproj,l_dstproj))
				{
					printf("\nCopy:\n\t%s\n\t%s\n",src_path,dst_path);
					mkdir(dst_path,S_IRWXU|S_IRWXG|S_IROTH|S_IXOTH);
					copy_dir(src_path,dst_path,l_srcproj,l_dstproj);
				}
			}
			else if (strstr(entry->d_name,u_srcproj))
			{
				strcpy(src_path,argv[1]);
				strcat(src_path,proj_path[i]);
				strcat(src_path,entry->d_name);
				strcpy(dst_path,src_path);
				if (replacestr(dst_path,u_srcproj,u_dstproj))
				{
					printf("\nCopy:\n\t%s\n\t%s\n",src_path,dst_path);
					mkdir(dst_path,S_IRWXU|S_IRWXG|S_IROTH|S_IXOTH);
					copy_dir(src_path,dst_path,u_srcproj,u_dstproj);
				}
			}
		}
		closedir(dirptr);
		}


		free(p);
	}


//list_start:
	// 在list文件添加
	strcpy(src_path,argv[1]);
	strcat(src_path,listfile);

	strcpy(dst_path,argv[1]);
	strcat(dst_path,listfile);
	strcat(dst_path,".1");
	printf(">>> %s\n",src_path);
	{
		FILE *is, *os;
		char x[512];
		char fstr[512];
		int matchfound = 0;

		remove(dst_path);
		rename(src_path,dst_path);

		is = fopen(dst_path,"rt");
		os = fopen(src_path,"wt");

		while (fgets(x,sizeof(x),is))
		{
			if (strstr(x,l_dstproj))
			{
				printf("found: %s\n",l_dstproj);
				matchfound = 1;
			}
			else if (strstr(x,u_dstproj))
			{
				printf("Found: %s\n",u_dstproj);
				matchfound = 1;
			}
			else
				fputs(x,os);
		}
		fclose(os);

		os = fopen(src_path,"a");
		fseek(is,0,SEEK_SET);

		while (fgets(x,sizeof(x),is))
		{
			int m = 0;

			if (strstr(x,"export MSM8916")) continue;
			if (x[0] == '#') continue;

			m += replacestr(x,l_srcproj,l_dstproj);
			m += replacestr(x,u_srcproj,u_dstproj);
			if (m)
				fputs(x,os);
		}


		fclose(os);
		fclose(is);		
	}
//	goto end_cpp;

	// 复制configs目录下特定文件
	strcpy(src_path,argv[1]);
	strcat(src_path,dir2touch);
	copyfilesindir(src_path);

	strcpy(src_path,argv[1]);
	strcat(src_path,dir2touch2);
	copyfilesindir(src_path);

	//conat char *vendordevfile = "/LINUX/android/vendor/qcom/proprietary/common/config/device-vendor.mk";	
	{
		FILE *is,*os;
		char buf[1024];
		int found = 0;
		char *pdevfile = malloc(strlen(vendordevfile)+strlen(argv[1])+32);
		char *pdevtemp = malloc(strlen(vendordevfile)+strlen(argv[1])+32);

		strcpy(pdevfile,argv[1]);
		strcat(pdevfile,vendordevfile);

		strcpy(pdevtemp,pdevfile);
		strcat(pdevtemp,".temp");
		remove(pdevtemp);
		rename(pdevfile,pdevtemp);
		is = fopen(pdevtemp,"rt");
		if (is)
		{
			printf("%s: \n",pdevfile);
			os = fopen(pdevfile,"wt");
			while (fgets(buf,sizeof(buf),is))
			{
				if (strstr(buf,l_dstproj))
				{
					printf("found: %s\n",l_dstproj);
					continue;
				}
				else if (strstr(buf,u_dstproj))
				{
					printf("found: %s\n",u_dstproj);
					continue;
				}
				fputs(buf,os);
				if (replacestr(buf,l_srcproj,l_dstproj))
				{
					found = 1;
					fputs(buf,os);
				}	
				else if (replacestr(buf,u_srcproj,u_dstproj))
				{
					found = 1;
					fputs(buf,os);
				}
			}
			fclose(os);
			fclose(is);
			printf("%d\n",found);
		}
		else
			printf("Can not open: %s\n",pdevfile);
	}

//end_cpp:
	free(src_path);
	free(dst_path);
	// done!
}

