import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key,required this.snap});
   final snap;

  @override
  Widget build(BuildContext context) {
    return Padding(
         padding: const EdgeInsets.symmetric(horizontal:12,vertical: 14),
         child: Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children:[
             CircleAvatar(backgroundImage: NetworkImage(snap['profileImage']),radius: 18,),    
             Padding(
               padding: const EdgeInsets.symmetric(horizontal:8.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,    
                 children:[
                   Text(snap['nickname'],style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onBackground),),
                   Text(snap['text'],style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onBackground),)
                 ]
              ),
             ),    
           ]
         ),
       );
  }
}
