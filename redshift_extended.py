__author__ = "Bruce Pannaman"

import subprocess
import os
import sys

print("Installing necessary libraries\n")
try:
    subprocess.call(["pip3", "install", "-r", "requirements.txt"], stdout=open(os.devnull, 'w'), stderr=subprocess.STDOUT)
except exception as e:
    print("Problem installing libraries automatically\n Please run\n\n pip3 install -r requirements.txt \n\n in terminal")
    sys.exit()

import psycopg2
from getpass import getpass
import sys
from progressbar import Percentage, Bar, ProgressBar
import time

class Redshift_Extended:
    def __init__(self):
        self.hostname = input("Input hostname of your redshift cluster \n> ")
        self.user = input("Input username of your redshift cluster \n(Need to have USAGE ON LANGUAGE SQL privileges)\n> ")
        self.password = getpass("Input password of the username entered above\n> ")
        self.port = input("Input port to access your redshift cluster)\n> ")
        self.db = input("Input main database name in your redshift cluster)\n> ")
        print("\n Thank you, attempting to connect to redshift")

        self.conn = None
        self.cursor = None
    
    def open_connection(self):
        try:
            conn_string = "dbname=%s port=%s user=%s password=%s host=%s" %(self.db, self.port, self.user, self.password, self.hostname)
            self.conn = psycopg2.connect(conn_string)
            self.cursor = self.conn.cursor()
            print("\n Successfully connnected to your Redshift cluster")
        except psycopg2.OperationalError as expt:
            print(type(e))
            print(e)

    def add_functions_to_redshift(self):
        print("\n Installing Redshift Extended Functions on your Cluster")
        pbar = ProgressBar(widgets=[Percentage(), Bar()], maxval=200).start()
        for i in range(200):
            self.cursor.execute(open("sql_script.sql", "r").read())
            time.sleep(0.01)
            pbar.update(i+1)
        pbar.finish()
            

    def close_connection(self):
        self.conn.commit()
        self.conn.close()


def main():
    reddy = Redshift_Extended()
    reddy.open_connection()
    reddy.add_functions_to_redshift()
    reddy.close_connection()

if __name__ == '__main__':
    main()
