public class Reservations {

    public static void main(String[] args) {
        
        System.out.println("Hello, World from Java " +
         System.getProperty("java.version"));
         
         Connection cn= DriverManager.getConnection("jdbc:mysql://repserver.intranet:4987/active?user=rbradstreet");
         Statement s= null;
         ResultSet rs= null;
         s= cn.createStatement(java.sql.ResultSet.TYPE_FORWARD_ONLY,
                               java.sql.ResultSet.CONCUR_READ_ONLY);
         s.setFetchSize(Integer.MIN_VALUE);
         s.execute("SELECT res_id FROM reservations WHERE filled= 0");
         rs= s.getResultSet();
         while (rs.next())
         {
           Reservation v= UnfilledReservation(rs.getInteger(1));
           LockReservation(v);
           FillReservation(rs.getInteger(1));
           UnlockReservation(v);
         }
         rs.close();
    
    }
}