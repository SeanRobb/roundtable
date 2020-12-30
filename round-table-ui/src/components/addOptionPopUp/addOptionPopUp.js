import React, { useState }  from 'react';
import styles from './addOptionPopUp.module.css';
import { Box, Dialog, DialogTitle, FormControl,InputLabel,Input, Grid, Button, DialogContentText } from '@material-ui/core';
import {createOption} from '../../utils/index';

const AddOptionPopUp = (props) => {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [choiceA, setChoiceA] = useState("");
  const [choiceB, setChoiceB] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault()
    createOption(props.gameId,{title,description,choiceA,choiceB})
    setTitle("")
    setDescription("")
    setChoiceA("")
    setChoiceB("")
    props.onClose()
  }
  return (
    <Dialog className={styles.rolePopup} data-testid="addOptionsPopup"
      open={props.open}
      onClose={props.onClose}
      >
      <Box className='popup\_inner' 
        style={{padding:'5px'}}
        >  
        <DialogTitle>
          Add Option
        </DialogTitle>
        <DialogContentText>
          Options a bet ideas that are presented to the captain. Once approved by a captain an option becomes an open bet.
        </DialogContentText>
        <form onSubmit={handleSubmit}>
          <Grid container
              direction='column'
              alignItems='stretch'
              justify='center'
              style={{padding:'5px'}}
              >
            <Grid item>
              <FormControl
                fullWidth={true}>
                <InputLabel htmlFor="event">Event</InputLabel>
                <Input 
                  id="event" 
                  value={title} 
                  onChange={(event)=>setTitle(event.target.value)}
                  fullWidth={true}
                  />
              </FormControl>
            </Grid>
            <Grid item>
              <FormControl
                fullWidth={true}>
                <InputLabel htmlFor="description">Bet Description</InputLabel>
                <Input 
                  id="description" 
                  value={description} 
                  onChange={(event)=>setDescription(event.target.value)}
                  fullWidth={true}
                  />
              </FormControl>
            </Grid>
            <Grid item>
              <Grid container
                direction='row'
                justify='space-around'
                alignItems='center'
                spacing={2}
                style={{padding:'5px'}}
                >
                <Grid item>
                  <FormControl>
                    <InputLabel htmlFor="choiceA">Choice A</InputLabel>
                    <Input 
                      id="choiceA"
                      fullWidth={true}
                      value={choiceA} 
                      onChange={(event)=>setChoiceA(event.target.value)}
                    />
                  </FormControl>
                </Grid>
                <Grid item>
                  <FormControl>
                    <InputLabel htmlFor="choiceB">Choice B</InputLabel>
                    <Input 
                      id="choiceB" 
                      fullWidth={true}
                      value={choiceB} 
                      onChange={(event)=>setChoiceB(event.target.value)}
                      />
                  </FormControl>
                </Grid>
              </Grid>
            </Grid>
            <Grid item>
              <Grid container
                justify='flex-end'
                >
                <Grid item>
                  <Button type="submit">
                    Submit
                  </Button>
                </Grid>
              </Grid>
            </Grid>
          </Grid>
        </form>
      </Box>  
    </Dialog>
)};

AddOptionPopUp.propTypes = {};

AddOptionPopUp.defaultProps = {};

export default AddOptionPopUp;
