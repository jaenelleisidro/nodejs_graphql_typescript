

import {
    GraphQLSchema,
    GraphQLObjectType,
    GraphQLList,
    GraphQLNonNull,
    GraphQLString,
    GraphQLInt,
    GraphQLBoolean,
    GraphQLID,
    GraphQLEnumType,
  } from "graphql";
  import UserType from "./User";
import prisma from "./../db";

  // Queries
  const RootQuery = new GraphQLObjectType({
    name: "RootQueryType",
    fields: {
      // Query to get all users
      users: {
        type: GraphQLList(UserType),
        args: {
          offset: { type:GraphQLInt },
          limit: { type: GraphQLInt },
        },
        resolve: async (_, args) => {
          try {
            const {offset = 0, limit = 10} = args;

            const users= await prisma.user.findMany({skip:offset,take:limit,orderBy:[{createdAt: 'desc'}]});

            return users.map(user => ({
              ...user,
              createdAt: user.createdAt.toISOString(), // Format createdAt as ISO 8601
              updatedAt: user.updatedAt.toISOString(), // Format createdAt as ISO 8601
            }));
          } catch (error) {
            throw new Error(error.message);
          }
        },
      },
  
      // Query to get a user by ID
      // user: {
      //   type: UserType,
      //   args: { id: { type: GraphQLNonNull(GraphQLID) } },
      //   resolve: async (_, args) => {
      //     try {
      //       const user = await prisma.user.findUniqueOrThrow({where:{id:parseInt(args.id)}});
      //       return {
      //         ...user,
      //         createdAt: user.createdAt.toISOString(),
      //         updatedAt: user.updatedAt.toISOString(),
      //       };
      //     } catch (error) {
      //       throw new Error(error.message);
      //     }
      //   },
      // },  
    },
  });
  
  const ServiceEnumType = new GraphQLEnumType({
    name: 'ServiceEnum',
    values: {
      DELIVERY: {
            value: 'DELIVERY',
        },
        PICKUP: {
            value: 'PICKUP',
        },
        PAYMENT: {
            value: 'PAYMENT',
        },
    },
});


  // Mutations
  const Mutation = new GraphQLObjectType({
    name: "Mutation",
    fields: {
      // Mutation to add a new user
      addUser: {
        type: UserType,
        args: {
          email: { type: GraphQLNonNull(GraphQLString) },
          name: { type: GraphQLNonNull(GraphQLString) },
          mobile: { type: GraphQLNonNull(GraphQLString) },
          postcode: { type: GraphQLNonNull(GraphQLString) },
          service: { type: GraphQLNonNull(ServiceEnumType) },
        },
  
        resolve: async (_, args) => {
          try {
            const { email, name, mobile, postcode, service } = args;
  
          return await prisma.user.create({
                data:{email,mobile,name,postcode,service}
            });
          } catch (error) {
            throw new Error(error.message);
          }
        },
      },
    },
  });
  
  export default new GraphQLSchema({
    query: RootQuery,
    mutation: Mutation,
  });