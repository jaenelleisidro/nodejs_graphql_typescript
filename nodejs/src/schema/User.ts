
  

import {
    GraphQLObjectType,
    GraphQLID,
    GraphQLString,
    GraphQLInt,
  } from "graphql";
  
  const UserType = new GraphQLObjectType({
    name: "User",
    fields: () => ({
      id: { type: GraphQLID },
      email: { type: GraphQLString },
      name: { type: GraphQLString },
      mobile: { type: GraphQLString },
      postcode: { type: GraphQLInt },
      service: { type: GraphQLString },
      createdAt: { type: GraphQLString },
    }),
  });
  export default UserType;