import java.sql.*;

// Remember that part of your mark is for doing as much in SQL (not Java) 
// as you can. At most you can justify using an array, or the more flexible
// ArrayList. Don't go crazy with it, though. You need it rarely if at all.
import java.util.ArrayList;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to the database and sets the search path.
     * 
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * markus.
     * 
     * @param url
     *            the url for the database
     * @param username
     *            the username to be used to connect to the database
     * @param password
     *            the password to be used to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        // Replace this return statement with an implementation of this method!
    String search_path = "SET SEARCH_PATH TO 'markus'";
    try {
        connection = DriverManager.getConnection(URL,username,password);
        PreparedStatement search = connection.prepareStatement(search_path); 
	      search.execute();
	      return true;
    }catch (SQLException e){
    	e.printStackTrace();
	      return false;
	    }
	
    }

    /**
     * Closes the database connection.
     * 
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
    try { 
        connection.close();
        return true; 
      }catch (SQLException e){
        e.printStackTrace();
        return false;
      }
    }

    /**
     * Assigns a grader for a group for an assignment.
     * 
     * Returns false if the groupID does not exist in the AssignmentGroup table,
     * if some grader has already been assigned to the group, or if grader is
     * not either a TA or instructor.
     * 
     * @param groupID
     *            id of the group
     * @param grader
     *            username of the grader
     * @return true if the operation was successful, false otherwise
     */
    public boolean assignGrader(int groupID, String grader) {
        // Replace this return statement with an implementation of this method!
        ResultSet rs;

        //checks if grader is not a student
        try{
        boolean check= false;
        String username2job = "select username, type from MarkusUser;";
        PreparedStatement prep = connection.prepareStatement(username2job);
        rs = prep.executeQuery();
        while (rs.next()){
             if (rs.getString ("username").equals(grader) && !rs.getString("type").equals("student"))
               check = true;
           } 
          if (!check)
            return false;
        
        check = false;
        //find the group if it exists
        String existanceOfGroup = "select * from AssignmentGroup;";
        prep = connection.prepareStatement(existanceOfGroup);
        rs = prep.executeQuery();
        while (rs.next()){
          if (rs.getInt("group_id")==groupID)
              check =true;
          }
          if (!check)
            return check;
          
        //Finds Grader already assigned to group if any
        String alreadyAssigned = "select * from Grader;"; 
        prep = connection.prepareStatement(alreadyAssigned);
        rs = prep.executeQuery();
        while (rs.next()){
        if (rs.getInt("group_id") != 0 && rs.getString("username") != null){
           if (rs.getInt("group_id") == groupID)
              return false;
              }
         }
          
        boolean update = false;
        String doupdate = "select * from Grader;"; 
        prep = connection.prepareStatement(doupdate);
        rs = prep.executeQuery();
        while (rs.next()){
        if (rs.getString("username") == null){
           if (rs.getInt("group_id") == groupID)
             update = true;
           }
         }
        String modify = null;
        
        if (update)      
        	modify = "update Grader set username = '" + grader + "' where group_id = " + groupID + ";";
        else 
        	modify = "insert into Grader values (" +groupID + ", '" + grader+"')";
        
        prep = connection.prepareStatement(modify);
        prep.execute();
        
        return true;
        }catch(SQLException e){
        	e.printStackTrace();
         return false;
        }
    }

    /**
     * Adds a member to a group for an assignment.
     * 
     * Records the fact that a new member is part of a group for an assignment.
     * Does nothing (but returns true) if the member is already declared to be
     * in the group.
     * 
     * Does nothing and returns false if any of these conditions hold: - the
     * group is already at capacity, - newMember is not a valid username or is
     * not a student, - there is no assignment with this assignment ID, or - the
     * group ID has not been declared for the assignment.
     * 
     * @param assignmentID
     *            id of the assignment
     * @param groupID
     *            id of the group to receive a new member
     * @param newMember
     *            username of the new member to be added to the group
     * @return true if the operation was successful, false otherwise
     */
    public boolean recordMember(int assignmentID, int groupID, String newMember) {
    	ResultSet rs;
    	try{
     boolean check = false;
    	//assignment does not exist check
    	String assignmentcheck = "Select * from Assignment;";
    	PreparedStatement ps = connection.prepareStatement(assignmentcheck);
    	rs = ps.executeQuery();
    	while (rs.next()){
       if (rs.getInt ("assignment_id") == assignmentID)
    		check = true;
        }
         if (!check)
            return false;
    	
     check = false;
    	//no group declared check
    	String noGroupDec = "Select * from AssignmentGroup where assignment_id = '"+ assignmentID + "' and group_id = '" + groupID +"';"; 
    	ps = connection.prepareStatement(noGroupDec);
    	rs = ps.executeQuery();
    	if (rs.next())
    		return false;
    	
        // max capacity groups
    	String at_capacityviews = "create view capacity as select assignment_id,group_max from Assignment;"
    			+ "create view memcount as select assignment_id , Membership.group_id, count (username) as membercount from assignmentGroup, Membership where AssignmentGroup.group_id = Membership.group_id Group by assignment_id , Membership.group_id;";
  			String qat_capacity = "select mc.group_id from memcount mc JOIN capacity c ON mc.assignment_id = c.assignment_id where mc.membercount = c. group_max;";
   	  ps = connection.prepareStatement(at_capacityviews);
    	rs = ps.execute();
    	
    	while (rs.next()){
    		if (rs.getInt("group_id") == groupID)
    			return false;
    	}
    	
    	//invalid name check
    	if (newMember.length() > 25)
    		return false;
    	
    	//student check
    	String student = "Select * from MarkusUsers where username = '" + newMember +"';";
    	ps = connection.prepareStatement(student);
    	rs = ps.executeQuery();
    	if (!rs.getString("type").equals("student"))
    		return false;
    	
    	//student already in groupID
    	String already = "Select username, group_id from Membership, AssignmentGroup where username = '" + newMember +"' and group_id = '"+ groupID +"';";
    	ps = connection.prepareStatement(already);
    	rs = ps.executeQuery();
    	if (!rs.next())
    		return true;
    	
    	
    	//all checks passed now to record
    	String Record ="insert into Memebership values ('"+newMember+"', " + groupID + ")";
    	ps = connection.prepareStatement(Record);
    	ps.execute();
    	return true;
    	
    	}catch (SQLException e){
    		e.printStackTrace();
        	return false;
    	}
    }

    /**
     * Creates student groups for an assignment.
     * 
     * Finds all students who are defined in the Users table and puts each of
     * them into a group for the assignment. Suppose there are n. Each group
     * will be of the maximum size allowed for the assignment (call that k),
     * except for possibly one group of smaller size if n is not divisible by k.
     * Note that k may be as low as 1.
     * 
     * The choice of which students to put together is based on their grades on
     * another assignment, as recorded in table Results. Starting from the
     * highest grade on that other assignment, the top k students go into one
     * group, then the next k students go into the next, and so on. The last n %
     * k students form a smaller group.
     * 
     * In the extreme case that there are no students, does nothing and returns
     * true.
     * 
     * Students with no grade recorded for the other assignment come at the
     * bottom of the list, after students who received zero. When there is a tie
     * for grade (or non-grade) on the other assignment, takes students in order
     * by username, using alphabetical order from A to Z.
     * 
     * When a group is created, its group ID is generated automatically because
     * the group_id attribute of table AssignmentGroup is of type SERIAL. The
     * value of attribute repo is repoPrefix + "/group_" + group_id
     * 
     * Does nothing and returns false if there is no assignment with ID
     * assignmentToGroup or no assignment with ID otherAssignment, or if any
     * group has already been defined for this assignment.
     * 
     * @param assignmentToGroup
     *            the assignment ID of the assignment for which groups are to be
     *            created
     * @param otherAssignment
     *            the assignment ID of the other assignment on which the
     *            grouping is to be based
     * @param repoPrefix
     *            the prefix of the URL for the group's repository
     * @return true if successful and false otherwise
     */
    public boolean createGroups(int assignmentToGroup, int otherAssignment,
            String repoPrefix) {
            /**
        try {
        ResultSet rs, rs2, rs3, temp;
        //extreme case
        String q = "select username from MarkusUser where type = 'student';";
        PreparedStatement ps = connection.preparedStatement (q);
        rs = ps.executeQuery();
        if (!rs.next())
          return true;
          
        //Finding maximum group_size
        q = "select group_max from Assignment where assignment = " + assignmentToGroup + ";";
        ps = connection.preparedStatement (q);
        rs = ps.executeQuery();
        rs.next();
        int max = rs.getInt("group_max");
        
        //finding every user in AssignmentToGroup and their total mark
        String mark_user = " select mark, username from Membership, Assignment, Result where Membership.group_id = Assignment.group_id"
        		+ " and Assignment.group_id = Result.group_id and Assignment = " + otherAssignment + " "
        				+ " ORDER BY mark DESC;";
        
        String mark_user2= " create view mark_user as select username from Membership, Assignment, Result where Membership.group_id = Assignment.group_id"
        		+ " and Assignment.group_id = Result.group_id and Assignment = " + otherAssignment + ";";
        
        String users = "create view users as Select username from Membership;";
        String nulls = "select * from (select * from users EXCEPT select * mark_users2) a ORDER BY a.username;";
        
        ps = connection.prepareStatement(mark_user);
        rs = ps.executeQuery();
        
        ps = connection.prepareStatement(users);
        ps.execute();
        ps = connection.prepareStatement(nulls);
        rs3 = ps.executeQuery();
        
        //Finding the maximum group_id from which we can start new groups without conflicting IDs
        int max_group_id = 0;
        String max_group = "Select max(group_id) as max_groupID from AssignmentGroup;";
        ps = connection.prepareStatement(max_group);
        rs2 = ps.executeQuery();
        rs2.next();
        
        max_group_id = rs2.getInt('max_groupID');
        
        
        q = "select setVal('AssignmentGroup_group_id_seq', "+ max_group_id +")";
        ps = connection.prepareStatement(q);
        ps.execute();
       
        
        int counter = max_group_id + 1;
        int current_group_count = 0;
        String add_user = null;
        String delete_user = null;
        String add_group = null;
        String username = null;
        String temps = null;
        String tempname = null;
        double mark = 0;
        boolean next = rs.next();
        boolean tempnext = false;
        
        while (next){
        	username = rs.getString('username');
        	mark = rs.getDouble('mark');
      
        	//insert a new group with new assignment
        	if (current_group_count == 0){
        		
        		add_group = "Insert into AssignmentGroup values (" + assignmentToGroup +" , '" + repoPrefix + "/group_+" + counter + "')";
    			ps = connection.prepareStatement(add_group);
    			ps.executeQuery();
        	}
        	
        	if (!tempnext){
        			temps = "Select mark, username from "
        					+ " (select mark, username from Membership, Assignment, Result where Membership.group_id = Assignment.group_id"
        						+ " and Assignment.group_id = Result.group_id and Assignment = " + otherAssignment + " "
        							+ " ORDER BY mark DESC) Where mark = " + mark + " ORDER BY username ASC;";
        		
    		ps = connection.prepareStatement(temps);
    		temp = ps.executeQuery(); 
        	}
        	tempnext = temp.next();
        	while (current_group_count != max && tempnext){
        	    tempname = temp.getString('username');
        		if (current_group_count < max){
        			delete_user = "delete from Membership where username = '"+ tempname +"';";    
        			ps = connection.prepareStatement(delete_user);
        			ps.execute();
        			
        			add_user = "insert into Membership values ('" + tempname +"', " + counter +");";
        			ps = connection.prepareStatement(add_user);
        			ps.execute();
        			next = rs.next();
        		}	
        		tempnext = temp.next();
        		current_group_count ++;
        		
        	}
        	
    		if (current_group_count == max){
    			current_group_count = 0;
    			counter ++;
    		}
    		
        }
        
        
        //add nulls
        
        
        
        
        return true;
        
        }catch (SQLException e){
        	System.out.println ("error in db");
        	return false;
        }
        */
        return false;
    }

    public static void main(String[] args) {
    	try {
            Assignment2 a2 = new Assignment2();

 //make sure to change the url and username
            boolean keks=a2.connectDB(
                    "jdbc:postgresql://localhost:5432/csc343h-fongadam",
                    "fongadam",
                    ""
            );
            System.out.println(keks);

            //=============================assignGrader=============================================
           boolean result;
           // member already in group
           result = a2.recordMember(1000,2000,"s1");
           System.out.println(result);
           // group at capacity
           result = a2.recordMember(1001,2001,"s2");
           System.out.println(result);
           // username DNE
           result = a2.recordMember(1000,2000,"coalesce");
           System.out.println(result);
           // username not student
           result = a2.recordMember(1000,2000,"i1");
           System.out.println(result);
           // assignment DNE
           result = a2.recordMember(9999,2000,"s1");
           System.out.println(result);
           //groupID DNE
           result = a2.recordMember(1000,5432,"s1");
           System.out.println(result);

           // successful insertion
           result = a2.recordMember(1000,2000,"s3");
           System.out.println(result);

           a2.disconnectDB();
       } catch (SQLException e) {
           e.printStackTrace();
       }    
}}
