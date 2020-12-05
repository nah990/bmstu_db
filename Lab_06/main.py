import psycopg2
#from password import dehash

MYPASSWORD = str(dehash('7f5f632a')) + "Proman"
CONTINUE = 0
SHUTDOWN = 1


def welcome_msg():
    print('\n1 - Выполнить скалярный запрос;\n'
          '2 - Выполнить запрос с несколькими соединениями (JOIN);\n'
          '3 - Выполнить запрос с ОТВ (CTE) и оконными функциями;\n'
          '4 - Выполнить запрос к метаданным;\n'
          '5 - Вызвать скалярную функцию (написанную в третьей лабораторной работе);\n'
          '6 - Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);\n'
          '7 - Вызвать хранимую процедуру (написанную в третьей лабораторной работе);\n'
          '8 - Вызвать системную функцию или процедуру;\n'
          '9 - Создать таблицу в базе данных, соответствующую тематике БД;\n'
          '10 - Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.\n'
          '\nЛюбая другая цифра - Выход\n')


class Menu(object):
    def __init__(self):
        self.menu_item = list(range(1, 11))
        self.conn = psycopg2.connect(database="db_matches", user="postgres",
                                     password=MYPASSWORD, host="localhost")
        self.cursor = self.conn.cursor()

    def psycopg2_close(self):
        self.cursor.close()
        self.conn.close()

    def menu_item_selection(self):
        argument = int(input('Выберите пункт меню - '))
        if argument not in self.menu_item: argument = 0
        method_name = 'menu_item_' + str(argument)
        method = getattr(self, method_name, lambda: "Unexpected error")
        return method()

    def menu_item_0(self):
        self.psycopg2_close()
        return SHUTDOWN

    def menu_item_1(self):
        self.cursor.execute('SELECT player_team FROM players_results WHERE player_name = %(player_name)s LIMIT 1',
                            {"player_name": "kennyS"})
        records = self.cursor.fetchall()
        print('\nКоманда игрока с ником kennyS -', records[0][0])
        return CONTINUE

    def menu_item_2(self):
        self.cursor.execute('SELECT pr.player_name, pr.player_country, mr.map_name, m.match_format ' +
                            'FROM players_results AS pr ' +
                            'JOIN maps_results AS mr ON pr.match_id = mr.match_id ' +
                            'JOIN matches AS m ON m.match_id = mr.match_id ' +
                            'WHERE pr.player_country LIKE %(land)s',
                            {"land": "%land%"})
        records = self.cursor.fetchmany(size=10)
        print('\n')
        for row in records:
            print(row)
        return CONTINUE

    def menu_item_3(self):
        self.cursor.execute('WITH CTE (player_id, player_kills) AS ' +
                            '( ' +
                            'SELECT player_id, count(player_kills) ' +
                            'FROM players_results ' +
                            'WHERE player_id IS NOT NULL ' +
                            'AND player_kills > 10' +
                            'GROUP BY player_id ' +
                            ') ' +
                            'SELECT DISTINCT player_id, AVG(player_kills) OVER (PARTITION BY player_id) ' +
                            'FROM CTE LIMIT 10')
        records = self.cursor.fetchall()
        print('\n')
        for row in records:
            print(row)
        return CONTINUE

    def menu_item_4(self):
        self.cursor.execute('SELECT tablename ' +
                            'FROM pg_tables ' +
                            'WHERE schemaname = %(type)s', {"type": "public"})
        records = self.cursor.fetchall()
        print('\n')
        print('Список таблиц "public":')
        for row in records:
            print(row[0])
        return CONTINUE

    def menu_item_5(self):
        self.cursor.execute('select get_country_count(%(country)s)', {"country": "Germany"})
        records = self.cursor.fetchall()
        print('\n')
        print('Кол-во немецких игроков:')
        for row in records:
            print(row[0])
        return CONTINUE

    def menu_item_6(self):
        self.cursor.execute('select get_player_kills()')
        records = self.cursor.fetchmany(size=10)
        print('\n')
        print('Информация о убийствах игрока:')
        print('player_id, kills_diff, kills_min, kills_max')
        for row in records:
            print(row)
        return CONTINUE

    def menu_item_7(self):
        print('Все игроки из команды KOVA удалены')
        self.cursor.execute('CALL delete_player_by_team(%(team)s)', {"team": "KOVA"})
        self.conn.commit()
        return CONTINUE

    def menu_item_8(self):
        self.cursor.execute('SELECT current_database()')
        record = self.cursor.fetchall()
        print('\nНа данный момент мы работаем в базе данных под названием ' + str(record[0][0]))
        return CONTINUE

    def menu_item_9(self):
        self.cursor.execute('CREATE TABLE IF NOT EXISTS players_transfer_table ( ' +
                            'transfer_info JSON ' +
                            '); ')

        self.conn.commit()
        return CONTINUE

    def menu_item_10(self):
        self.cursor.execute('DELETE FROM players_transfer_table; ' +
                            'COPY players_transfer_table '
                            'FROM %(json_path)s ',
                            {"json_path": "C:/Labs/Database_Labs/bmstu_db/Lab_05/transfer.json"})

        '''
        self.conn.close()
        self.conn = psycopg2.connect(database="db_matches", user="postgres",
                                     password=MYPASSWORD, host="localhost")
        self.cursor = self.conn.cursor()
        self.cursor.execute('SELECT * FROM players_transfer_table')
        records = self.cursor.fetchall()
        print(records[0][0])'''
        
        self.conn.commit()
        return CONTINUE


if __name__ == '__main__':
    welcome_msg()
    menu_copy = Menu()
    while True:
        welcome_msg()
        if menu_copy.menu_item_selection() == SHUTDOWN:
            break

#select * from pg_stat_activity where datname = 'db_matches';