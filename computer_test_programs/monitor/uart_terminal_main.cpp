#define _CRT_SECURE_NO_WARNINGS
#include <Windows.h>
#include <stdio.h>
#include <process.h> // needed for _beginthread()

#define NCURSES_MOUSE_VERSION
#include <curses.h>
#include "serial_comm/serial_init.h"
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cstdio>

#define NUMBER_OF_MEASUREMENTS 128+32
#define SPACE_BETWEEN_COLUMNS 20

//-------------------------------------------------- 

void gui_plot(void *args)
{
	void** readargs;
	readargs = (void**)args;
	semaphore* read_port = (semaphore*)*(readargs+1);

    int* ad_data_vector = (int*)readargs[3];
    float ad_measurements[NUMBER_OF_MEASUREMENTS];

    int row,col; // to store the number of rows and the number of colums of the screen
	initscr();
    getmaxyx(stdscr,row,col);    // get the number of rows and columns
    resize_term(35, 120);
    getmaxyx(stdscr,row,col);    // get the number of rows and columns
	start_color();

	init_pair(1, COLOR_GREEN, COLOR_BLACK);
	init_pair(2, COLOR_CYAN, COLOR_BLACK);
	init_pair(3, COLOR_BLACK, COLOR_YELLOW);
	init_pair(4, COLOR_BLACK, COLOR_GREEN);

    const char* lower_border[] ={"------------------------------------------------------------------------------------------------------"};
    const char* ad_measurement_labels[] = {"AC voltage     ",
                                           "DC link voltage",
                                           "PFC current 1  ",
                                           "PFC current 2  ",
                                           "DAB voltage    ",
                                           "DAB current    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC voltage    ",
                                           "LLC current    "
                                            };

	keypad(stdscr, TRUE);
	noecho();
    cbreak();
    while (read_port->quit == 0)
    {
        if (read_port->data_ready == 1)
        {
            read_port->acknowledge = 1;
            clear();

            int current_column = 0;
            int number_of_rows = 32;
            char buffer[50];
            for (int q = 0; q < NUMBER_OF_MEASUREMENTS; q++)
            {
                sprintf(buffer,"%X : 0x%X", q, ad_data_vector[q]);
                if (q % number_of_rows != 0 || q == 0)
                {
                    attron(COLOR_PAIR(1));
                    mvprintw(q-number_of_rows*current_column + 2, SPACE_BETWEEN_COLUMNS*current_column + 2, buffer);
                    attroff(COLOR_PAIR(1));
                }
                else
                {
                    current_column++;
                    attron(COLOR_PAIR(1));
                    mvprintw(q-number_of_rows*current_column + 2, SPACE_BETWEEN_COLUMNS*current_column + 2, buffer);
                    attroff(COLOR_PAIR(1));
                } 

                //attron(COLOR_PAIR(2));
                //mvprintw(5, 2, *lower_border);
                //attroff(COLOR_PAIR(2));

			} 
            read_port->acknowledge = 0;
            refresh();
        }
        else
        {}
    }

	endwin();
}
//-------------------------------------------------- 

void data_population(void *args)
{
	void** readargs;
	readargs = (void**)args;

    HANDLE hSerial = (void*)*(readargs);
    int* ad_measurements = (int*)readargs[3];

	DWORD eventMask = EV_RXCHAR;
	BOOL retVal = FALSE;
	DWORD dwBytesRead = 0;
    retVal = WaitCommEvent(hSerial, &eventMask, NULL);
	BOOL	read_status = false;

	unsigned char szBuff[2] = { 0 };

    memset(szBuff, 0, 2);

	semaphore* read_port = (semaphore*)*(readargs+1);
    while (read_port->quit == 0)
    {
        for (int i=0; i < NUMBER_OF_MEASUREMENTS; i++)
        {
            read_status = ReadFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
            ad_measurements[i] = (((short int)szBuff[0]) << 8) & 0xFF00;
            ad_measurements[i] |= ((short int)szBuff[1]) & 0x00FF; 
            // add vector for power supply state indicators
        }
        if (read_port->acknowledge == 0)
        {
            read_port->data_ready = 1;
        }
        else
        {
            read_port->data_ready = 0;
        }
    }
}
//-------------------------------------------------- 

int main(void)
{	
	HANDLE hSerial{};
	HANDLE receiverThread = NULL;
	semaphore read_port;
	
	hSerial = (HANDLE)init_serial();

	short unsigned int senddata;

	using std::string;
	using std::cout;
	using std::endl;

	string streambuf;

	//init semaphore between threads

	read_port.acknowledge = 0;
	read_port.writeok = 0;
	read_port.data_ready = 0;
	read_port.recievemsg = 0;
	read_port.quit = 0;

    int ad_measurements[NUMBER_OF_MEASUREMENTS];

	void* writeportargs[4];
	writeportargs[0] = (void*)hSerial;
	writeportargs[1] = &read_port;
	writeportargs[2] = NULL;
    writeportargs[3] = &ad_measurements;

	//start threaded functions
	_beginthread(gui_plot, 0, (void*)writeportargs );
	_beginthread(data_population, 0, (void*)writeportargs );

	MEVENT event;
    int ch = 0;

    char msg[]="What is your name: ";
	char str[80];

    // initscr();	
	addstr(msg);
	getstr(str);
	/* move(0, 0); */
	/* clrtoeol(); */
	mvprintw(22, 0, "Welcome to curses %s", str);
	getch();
	// endwin();
    WINDOW* inputwin = newwin(5,20,40,5);
    box(inputwin,0,0);
    wrefresh(inputwin);
    keypad(inputwin, true);

    bool close_not_clicked = true;
	while(close_not_clicked)
	{
		ch = getch();
		if(ch == KEY_MOUSE) 
        {
			if(getmouse(&event) == OK)
			{
				if(event.bstate & BUTTON1_CLICKED and ((event.x >= 1) && (event.x < 15) && (event.y == 23)))
                {
                    close_not_clicked = false;
                    read_port.quit = 0;
                }
				else if(event.bstate & BUTTON1_CLICKED and ((event.x >= 1) && (event.x < 15) && (event.y == 20)))
                {
                }
            }
            wrefresh(inputwin);
        }
    }
    
    read_port.quit = 0;
    Sleep(3000);
    PurgeComm(hSerial,PURGE_RXCLEAR); //clear the filebuffer
	CloseHandle(hSerial);

	return 0;
}
