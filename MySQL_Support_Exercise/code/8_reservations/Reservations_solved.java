import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class Reservations {

        public static void main(String[] args) throws SQLException {

                //Connection cn= DriverManager.getConnection("jdbc:mysql://repserver.intranet:4987/active?user=rbradstreet");
                Connection   cn= DriverManager.getConnection("jdbc:mysql://localhost:3306/mysql?user=root" +
                        "&password=JNOhdkbe3j,U&useLegacyDatetimeCode=false&serverTimezone=America/Tijuana");
                Statement s= null;
                ResultSet rs= null;
                s= cn.createStatement(java.sql.ResultSet.TYPE_FORWARD_ONLY,
                                      java.sql.ResultSet.CONCUR_READ_ONLY);
                s.setFetchSize(Integer.MIN_VALUE);
                //s.execute("SELECT res_id FROM reservations WHERE filled= 0");
                  s.execute("SELECT user   FROM mysql.user   WHERE host LIKE '%localhost%'");
                rs= s.getResultSet();
                while (rs.next())
                {
                        //Reservation v= UnfilledReservation(rs.getInteger(1));
                        String        v=                     rs.getString(1);
                        System.out.println(v);
                        /*LockReservation(v);
                        FillReservation(rs.getInteger(1));
                        UnlockReservation(v);*/
                }
                rs.close();
        }
}
