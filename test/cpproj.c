#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>


const unsigned char *extstr[] = {".c",".cc",".cpp",".h",".hpp",".java",".s",".xml"};
#define numofext 8

inline char* strlwr( char* str )
{
	char* orig = str;
	// process the string
	for ( ; *str != '\0'; str++ )
	*str = tolower(*str);
	return orig;
}

int checkfileext(char *name, char *ext)
{
	int ext_size = strlen(ext);
	char *p = strstr(name,ext);
	if (!p) return 0;
	if (!p[ext_size]) return 1;
	return 0;
}

int listdir(char *p, char *q)
{
	DIR *dirptr = NULL;
	struct dirent *entry;

	if (!(dirptr = opendir(p)))
	{
		printf("open dir !");
		return 1;
	}
	else
	{
//		printf("-----%s-----\n",p);
		while (entry = readdir(dirptr))
		{
			int pl,ql,nl;

			if (entry->d_name[0]=='.') continue;
/*
			if (!strcmp(entry->d_name,".")) continue;
			if (!strcmp(entry->d_name,"..")) continue;
			if (!strcmp(entry->d_name,".svn")) continue;
*/
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

			if (entry->d_type==DT_DIR)
			{
				mkdir(dirq,0x777);
				listdir(dirp,dirq);
			}
			else
			{	// \.java$|\.c$|\.cpp$|\.h$|\.hpp$
				//FILE *is;
				int enced = 0;
				int i;

				struct stat buf;

				char *tempname = malloc(strlen(dirp)+2);
				strcpy(tempname,dirp);
				strlwr(tempname);
				
				for (i=0;i<numofext;i++)
				{
					enced = checkfileext(tempname,(char*)extstr[i]);
					if (enced) break;
				}

				char *fstr = malloc(pl+nl+2+ql+nl+2+32);
				stat(dirp,&buf);

				if (checkfileext(tempname,".xml"))
				{
					strcpy(fstr,"cat \"");
					strcat(fstr,dirp);
					strcat(fstr,"\" | tee \"");
					strcat(fstr,dirq);
					strcat(fstr,"\"");
					system(fstr);
					printf("file: %s\n", dirq);
				}
				/*
				if (enced)//(ph||pjava||pc||phpp||pcpp||ps||pcc)
				{
					strcpy(fstr,"cat \"");
					strcat(fstr,dirp);
					strcat(fstr,"\" | tee \"");
					strcat(fstr,dirq);
					strcat(fstr,"\"");
					system(fstr);
					printf("file: %s\n", dirq);
				}
				else //if ((buf.st_mode&(S_IXOTH|S_IXGRP|S_IXUSR))&&(!ph)&&(!pjava)&&(!pc)&&(!pcpp)&&(!phpp)&&(!ps))
				{
					strcpy(fstr,"cp \"");
					strcat(fstr,dirp);
					strcat(fstr,"\" \"");
					strcat(fstr,dirq);
					strcat(fstr,"\"");
					system(fstr);
					printf("cp: %s\n", dirq);
				} */
				free(fstr);
				free(tempname);
			}
			
			free(dirq);
			free(dirp);
		}

		closedir(dirptr);
	}
	return 0;
}

int main(int argi, char *argv[])
{
	int al;
	if (argi>=3)
	{
		mkdir(argv[2],0x777);
		listdir(argv[1],argv[2]);
	}
	if (argi==4)
	{
		char x[1024];
		strcpy(x,"cp -fr ");
		strcat(x,argv[1]);
		strcat(x," ");
		strcat(x,argv[3]);
		system(x);
	}
} 
